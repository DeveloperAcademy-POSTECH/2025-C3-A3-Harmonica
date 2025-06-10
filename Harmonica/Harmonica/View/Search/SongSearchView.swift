import SwiftUI
import ShazamKit
import AVFoundation

// 곡 정보 데이터모델
struct SongInfo: Hashable {
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
}

// 곡 인식 관리 클래스
class ShazamRecognizer: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private let matchDelegate = MatchDelegate()
    
    @Published var matchedSong: SHMediaItem?
    @Published var didNotFindSong: Bool = false // 실패 여부 상태 추가
    
    override init() {
        super.init()
        session.delegate = matchDelegate
        
        // 노래 매칭시 결과처리
        matchDelegate.onMatch = {
            [weak self] mediaItem in DispatchQueue.main.async {
                self?.matchedSong = mediaItem
                self?.stopListening() // 매칭완료시 자동종료
            }
        }
        // 만약 매칭되는 결과가 없을 경우 처리방법
        matchDelegate.onNoMatch = { [weak self] in
            DispatchQueue.main.async {
                self?.matchedSong = nil
                self?.didNotFindSong = true // 실패 상태 표시
                self?.stopListening()
            }
        }
    }
    
    // 노래 들을 때 함수
    func startListening() throws {
#if targetEnvironment(simulator)
        print("⚠️ 시뮬레이터에서는 마이크 인식이 비활성화됩니다.")
        return
#else
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        session.delegate = matchDelegate
        
        inputNode.removeTap(onBus: 0) // 혹시 이전 tap이 남아있을 경우 대비
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            self.session.matchStreamingBuffer(buffer, at: time)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
#endif
    }
    // 노래 듣기 마치는 함수
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}

// SHSession 결과처리 델리게이트
class MatchDelegate: NSObject, SHSessionDelegate {
    var onMatch: ((SHMediaItem) -> Void)?
    var onNoMatch: (() -> Void)? // 실패 콜백 추가
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        onMatch?(mediaItem)
    }
    func session(_ session: SHSession, didNotFindMatchFor signature: SHSignature) {
        // ❗ 곡을 찾지 못했을 때 실행됨
        onNoMatch?()
    }
}

// 네비게이션 타겟
enum NavigationTarget: Hashable {
    case result(SongInfo?)
}

// 음악인식 검색 뷰
struct SongSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var recognizer = ShazamRecognizer()
    @State private var promptText = "노래를 들려주세요"
    @State private var permissionChecked = false
    @Binding var path: NavigationPath
    
    //    @State private var isShowPermissionAlert = false
    //    @State private var isShowRecognizerAlert = false
    //    @State private var isMatchFound = false
    
    // 마이크 권한 요청
    private func requestMicPermission() async -> MicPermissionStatus {
        let permission = AVAudioApplication.shared.recordPermission
        switch permission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { granted in
                    continuation.resume(returning: granted ? .granted : .denied)
                }
            }
        @unknown default:
            return .undetermined
        }
    }

    // 마이크 사용권한 확인 & 샤잠 자동실행
    private func startRecognitionFlow() async {
        let permission = await requestMicPermission()
        if permission == .granted {
            promptText = "노래를 들려주세요. 듣고 있어요"
            recognizer.didNotFindSong = false
            recognizer.matchedSong = nil
            try? recognizer.startListening()
        } else {
            promptText = "⚠️ 마이크 권한이 필요합니다"
        }
    }

    // 검색 재시작 전 초기화 포함
    private func restartListening() async {
        recognizer.stopListening()
        await startRecognitionFlow()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("이전") {
                    path = NavigationPath() // 메인 뷰로 복귀
                }
                Spacer()
                
                Button("검색") {
                    Task {
                        await startRecognitionFlow()
                    }
                }
            }
            Spacer()
            
            // 💛 To-do : [로띠 애니메이션으로 대체될 부분]
            Image(systemName: "waveform")
                .resizable()
                .frame(width: 200, height: 200)
                .symbolEffect(.breathe)
            
            Spacer()
            
            Text(promptText)
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.5), value: promptText)
        }
        // 화면 진입시 마이크 사용권한 확인 & 샤잠 자동실행
        .onAppear {
            Task {
                if !permissionChecked {
                    permissionChecked = true
                    await startRecognitionFlow()
                } else {
                    await restartListening() // 다시 돌아왔을 때도 자동 시작
                }
            }
        }
        // 곡 검색에 성공시 matchedSong을 감지하여 상태변경
        .onReceive(recognizer.$matchedSong) { item in
            if let item = item {
                let info = SongInfo(
                    title: item.title ?? "제목 없음",
                    artist: item.artist ?? "아티스트 없음",
                    artworkURL: item.artworkURL,
                    previewURL: item.appleMusicURL
                )
                path.append(NavigationTarget.result(info))
            }
        }
        // 매치하는 곡 검색에 실패시
        .onReceive(recognizer.$didNotFindSong) { notFound in
            if notFound {
                path.append(NavigationTarget.result(nil))
            }
        }
        Spacer()
    }
}

