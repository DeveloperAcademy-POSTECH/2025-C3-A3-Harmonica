import SwiftUI
import ShazamKit
import AVFoundation

// 곡 인식 관리 클래스
class ShazamRecognizer: NSObject, ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let session = SHSession()
    private let matchDelegate = MatchDelegate()
    
    @Published var matchedSong: SHMatchedMediaItem?
    
    override init() {
        super.init()
        session.delegate = matchDelegate
        matchDelegate.onMatch = {
            [weak self] mediaItem in DispatchQueue.main.async {
                self?.matchedSong = mediaItem
                self?.stopListening() // 매칭된 후 자동으로 종료됨
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
    var onMatch: ((SHMatchedMediaItem) -> Void)?
    
    func session(_ session: SHSession, didFind match: SHMatch) {
        guard let mediaItem = match.mediaItems.first else { return }
        onMatch?(mediaItem)
    }
}

// 음악인식 검색 뷰
struct SongSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var recognizer = ShazamRecognizer()
    
    var body: some View {
        VStack() {
            HStack {
                if let item = recognizer.matchedSong {
                    Text("Title: \(item.title ?? "Unknown")")
                    Text("Artist: \(item.artist ?? "Unknown")")
                } else {
                    Text("듣고 있어요...")
                }
                Button(action: {
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
            
            // (아직 미적용)모니카의 요청: 텍스트를 한줄로 - 검색시작 1초 이후 "지금 들려주세요 듣고있어요"
            Text("노래를 들려주세요 ")
                .font(
                    Font.custom("SF Pro", size: 64)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
            Spacer()
        }
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨김
        
        .onAppear {
            try? recognizer.startListening()
        }
    }
}
