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
        //        player?.pause()
        //        player = nil
        queuePlayer?.pause()
        queuePlayer = nil
        looper = nil
    }
}

// 검색결과를 시각적으로 표시하는 뷰
struct SearchResultView: View {
    let songInfo: SongInfo
    
    @StateObject private var audioPlayer = PreviewAudioPlayer()
    
    var body: some View {
        VStack{
            Text("찾으시던게 이 노래인가요?")
                .font(
                    Font.custom("SF Pro", size: 64)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
            ZStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 896, height: 366)
                    .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                    .cornerRadius(20)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 848, height: 318)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(30)
                HStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 270, height: 270)
                        .background(Color(red: 0.7, green: 0.7, blue: 0.7))
                        .cornerRadius(100)
                    Text(songInfo.title)
                        .font(
                            Font.custom("SF Pro", size: 64)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                }
            }
            ZStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 910, height: 205)
                    .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                    .cornerRadius(20)
                HStack{
                    ZStack{
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 419, height: 157)
                            .background(Color(red: 0.75, green: 0.75, blue: 0.75))
                            .cornerRadius(30)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 362, height: 121)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(100)
                            .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .inset(by: 1.5)
                                    .stroke(.white.opacity(0.7), lineWidth: 3)
                            )
                        Text("다시 노래 찾기")
                            .font(
                                Font.custom("SF Pro", size: 48)
                                    .weight(.medium)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                    }
                    ZStack{
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 419, height: 157)
                            .background(Color(red: 0.83, green: 0.81, blue: 0.78))
                            .cornerRadius(30)
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 362, height: 121)
                            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                            .cornerRadius(100)
                            .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 100)
                                    .inset(by: 1.5)
                                    .stroke(.white.opacity(0.7), lineWidth: 3)
                            )
                        Text("연습하러가기")
                            .font(
                                Font.custom("SF Pro", size: 48)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                    }
                }
            }
        }
        .task {
            if let previewURL = songInfo.previewURL {
                await audioPlayer.play(from: previewURL)
            }
        }
        .onDisappear {
            audioPlayer.stop()
        }
    }
}

