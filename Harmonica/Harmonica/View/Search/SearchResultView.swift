import SwiftUI
import ShazamKit

struct SearchResultView: View {
    let matchedSong: SHMatchedMediaItem?
    
    var body: some View {
        VStack{
            // 곡매칭 성공시
            if let song = matchedSong {
                Text("찾으시던게 이 노래인가요?")
                    .font(
                        Font.custom("SF Pro", size: 64)
                            .weight(.medium)
                    )
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                Text("🎵 \(song.title ?? "제목 없음")")
                Text("👤 \(song.artist ?? "아티스트 없음")")
            } else { // 곡매칭 실패시
                Text("원하시는 곡을 찾지 못했어요. 다시 한번 검색해주세요.")
            }
        }
        .font(.title)
        .navigationTitle("검색 결과")
    }
}
