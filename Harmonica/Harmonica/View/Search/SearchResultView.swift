import SwiftUI
import AVFoundation

// 검색결과 미리듣기 자동재생
@MainActor
final class PreviewAudioPlayer: ObservableObject {
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    func play(from url: URL) async {
        // 네트워크로 URL 준비 → AVAsset으로 만들기
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // 실제 재생 준비
        //        player = AVPlayer(playerItem: item)
        let player = AVQueuePlayer()
        self.queuePlayer = player
        self.looper = AVPlayerLooper(player: player, templateItem: item)
        player.play()
        
        // 짧은 지연 후 (네트워크 상황 고려)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
    }
    
    func stop() {
        queuePlayer?.pause()
        queuePlayer = nil
        looper = nil
    }
}

// 검색결과 뷰
struct SearchResultView: View {
    let songInfo: SongInfo?
    @Binding var path: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @StateObject private var audioPlayer = PreviewAudioPlayer()

    var body: some View {
        Group {
            if let info = songInfo {
                VStack(spacing: 20) {
                    Text("찾으시는 곡이 맞나요?")
                        .font(Font.custom("SF Pro", size: 64).weight(.medium))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))

                    HStack {
                        if let artworkURL = info.artworkURL {
                            AsyncImage(url: artworkURL) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Color.gray.opacity(0.2)
                                        ProgressView()
                                    }
                                case .success(let image):
                                    image.resizable().scaledToFit()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding()
                        }

                        VStack {
                            Text(info.artist).font(.headline)
                            Text(info.title).font(.title)
                        }
                        .padding()
                    }

                    Button("다시 노래 찾기") {
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                VStack(spacing: 16) {
                    Text("요청하신 노래를 찾지 못했습니다. 다시 검색해주세요.")
                        .font(.title2)
                        .foregroundColor(.gray)

                    HStack {
                        Button("처음으로 가기") {
                            path = NavigationPath()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("다시 노래 찾기") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .task {
            if let url = songInfo?.previewURL {
                await audioPlayer.play(from: url)
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
}

// [테스트용]
//class MockShazamRecognizer: ObservableObject {
//    @Published var matchedSong: SHMediaItem?
//    @Published var didNotFindSong: Bool = false
//
//    func simulateMatch() {
//        // 직접 SHMediaItem을 모킹하려면 KVC 또는 SongInfo로 대체 필요
//    }
//}

struct RandomSearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        RandomSearchResultView()
    }
}
