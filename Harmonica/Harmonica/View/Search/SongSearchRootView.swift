import Foundation
import SwiftUI
import ShazamKit

// 화면이동 제어루트
enum SearchRoute: Hashable {
    case result(SHMatchedMediaItem?)
}

struct SongSearchRootView: View {
    @State private var path: [SearchRoute] = [] // 화면 이동을 관리하는 Stack

    var body: some View {
        NavigationStack(path: $path) {
            SongSearchView { matchedSong in
                path.append(.result(matchedSong)) // 인식 완료 → 결과 뷰로 이동
            }
            .navigationDestination(for: SearchRoute.self) { route in
                switch route {
                case .result(let song):
                    SearchResultView(matchedSong: song)
                }
            }
        }
    }
}
