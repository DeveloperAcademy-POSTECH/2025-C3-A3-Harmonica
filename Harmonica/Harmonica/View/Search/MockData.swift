//import Foundation
//import SwiftUI
//
//struct MockSongs {
//    static let song1 = Song_Info(
//        title: "내 여자 내 남자",
//        artist: "배금성",
//        artworkURL: URL(string:
//                            "https://is2-ssl.mzstatic.com/image/thumb/Music126/v4/68/93/11/68931163-ef1f-c69a-0a0d-0b4d0cfb2479/859722652569_cover.jpg/200x200bb.jpg"),
//        previewURL: URL(string:
//                            "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/23/45/67/234567ab-cdef-89ab-cdef-234567abcdef/mzaf_1234567890123456789.plus.aac.p.m4a"))
//    static let song2 = Song_Info(
//        title: "인생대로 60번길",
//        artist: "윤정아",
//        artworkURL: URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music126/v4/ab/cd/ef/abcdef12-3456-7890-abcd-ef1234567890/cover.jpg/200x200bb.jpg"),
//        previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/ba/dc/fe/badcfeba-dcba-0987-fedc-ba9876543210/mzaf_0987654321098765432.plus.aac.p.m4a")
//    )
//    static let song3 = Song_Info(
//        title: "나그네 고향",
//        artist: "진성",
//        artworkURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Music116/v4/12/34/56/12345678-90ab-cdef-1234-567890abcdef/cover.jpg/200x200bb.jpg"),
//        previewURL: URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/98/76/54/98765432-10fe-dcba-9876-54321fedcba0/mzaf_1122334455667788990.plus.aac.p.m4a")
//    )
//}
//
//struct RandomSearchResultView: View {
//    @State private var path = NavigationPath()
//    var body: some View {
//        let candidates: [Song_Info?] = [MockSongs.song1, MockSongs.song2, MockSongs.song3, nil]
//        let selected: Song_Info? = candidates.randomElement()!
//        
//        return NavigationStack(path: $path) {
//            SearchResultView(song_Info: selected, path: $path)
//        }
//    }
//}
//
//struct MockSearchResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            RandomSearchResultView()
//        }
//    }
//}
