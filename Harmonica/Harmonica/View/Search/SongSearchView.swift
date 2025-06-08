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
    @Published var didNotFindSong: Bool = false // ❗ 실패 여부 상태 추가
    
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
                self?.didNotFindSong = true // ❗ 실패 상태 표시
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
        guard !isListening else { return }
        
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
    var onNoMatch: (() -> Void)? // ❗ 실패 콜백 추가
    
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
    @State private var permissionMessage = ""
    @State private var isShowPermissionAlert = false
    @State private var isShowRecognizerAlert = false
    @State private var promptText = "노래를 들려주세요"
    @State private var isMatchFound = false
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack() {
                HStack {
                    Button(action: {
                        Task {
                            let permissionStatus = await requestMicPermission()
                            if permissionStatus == .granted {
                                startSongRecognition()
                            } else {
                                // 권한 비허용시 사용자에게 안내하기
                                permissionMessage = "마이크 권한이 필요합니다."
                                isShowPermissionAlert = true
                            }
                        }
                        presentationMode.wrappedValue.dismiss()
                        try? recognizer.startListening()
                    }) {
                        // [이전(돌아가기) 버튼]
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 150, height: 110)
                                .background(Color(red: 0.34, green: 0.34, blue: 0.34))
                                .cornerRadius(20)
                            Image("Ellipse 11")
                                .frame(width: 120, height: 82)
                                .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                            Text("이전")
                                .font(
                                    Font.custom("SF Pro", size: 48)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 0.92, green: 0.91, blue: 0.87))
                        }
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
                
                // [waveform 애니메이션 이미지 삽입]
                ZStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 260, height: 260)
                        .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                        .cornerRadius(260)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 238, height: 238)
                        .background(Color(red: 0.92, green: 0.9, blue: 0.88))
                        .cornerRadius(260)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                    Image(systemName: "waveform")
                        .resizable()
                        .frame(width: 238, height: 238)
                        .symbolEffect(.breathe)
                }
                Spacer()
                
                Text(promptText)
                    .font(
                        Font.custom("SF Pro", size: 64)
                            .weight(.medium)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: promptText)
                Spacer()
            }
            .navigationDestination(for: NavigationTarget.self) { target in
                switch target {
                case .result(let songInfo):
                    SearchResultView(songInfo: songInfo, path: $path) // 바인딩 전달
                }
            }
        }
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨김
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    promptText = "지금 들려주세요. 듣고 있어요"
                }
            }
        }
        // matchedSong 감지하여 상태변경
        .onReceive(recognizer.$matchedSong) { item in
            if let item = item {
                let info = SongInfo(
                    title: item.title ?? "제목 없음",
                    artist: item.artist ?? "아티스트 없음",
                    artworkURL: item.artworkURL,
                    previewURL: item.safePreviewURL
                )
                path.append(NavigationTarget.result(info)) // 검색성공 케이스
            }
        }
        
        .onReceive(recognizer.$didNotFindSong) { notFound in
            if notFound {
                path.append(NavigationTarget.result(nil)) // 검색실패 케이스
            }
        }
    }
}

extension SongSearchView{
    
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
    
    private func startSongRecognition() {
        try? recognizer.startListening()
    }
    
    private func stopSongRecognition() {
        recognizer.stopListening()
    }
}

extension SHMediaItem {
    var safePreviewURL: URL? {
        return self.value(forKey: "appleMusicPreviewURL") as? URL
    }
}
