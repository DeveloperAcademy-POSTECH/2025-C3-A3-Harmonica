import SwiftUI
import AVFoundation

// 검색결과 미리듣기 자동재생
@MainActor
final class PreviewAudioPlayer: ObservableObject {
    //    private var player: AVPlayer?
    private var queuePlayer: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    
    func play(from url: URL) async {
        // 네트워크로 URL 준비 → AVAsset으로 만들기
        let asset = AVURLAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // 실제 재생을 준비
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
    @Binding var path: NavigationPath  // 처음(메인)으로 돌아가기
    @Environment(\.dismiss) private var dismiss  // 뒤로가기용 환경변수
    @StateObject private var audioPlayer = PreviewAudioPlayer()
    
    var body: some View {
        VStack(spacing: 20) {
            if let info = songInfo{
                // 검색 성공시
                VStack(spacing: 20) {
                    Text("찾으시는 곡이 맞나요?")
                        .font(
                            Font.custom("SF Pro", size: 64)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                    Text(info.title).font(.title)
                    Text(info.artist).font(.headline)
                    
                    if let artworkURL = info.artworkURL {
                        AsyncImage(url: artworkURL) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Spacer()
                }
                .padding()
                .task {
                    if let url = songInfo?.previewURL {
                        await audioPlayer.play(from: url)
                    }
                }
                .onDisappear {
                    audioPlayer.stop()
                }
            } else {
                // 검색 실패시
                VStack(spacing: 16){
                    Text("요청하신 노래를 찾지 못했습니다. 다시 검색해주세요.")
                        .font(.title2)
                        .foregroundColor(.gray)
                    HStack {
                        // 처음으로 가기 버튼
                        Button("처음으로 가기") {
                            path = NavigationPath()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        // 다시 노래 찾기 버튼
                        Button("다시 노래 찾기") {
                            dismiss()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
