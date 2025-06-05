import Foundation
import SwiftData

@Model
class Song {
    @Attribute(.unique) var id: Int // 중복되면 안 되는 값
    var title: String
    var artist: String
    var arFileName: String
    var mrFileName: String
    var lyricsFileName: String
    var bpm: Int
//    var startTime: Double
//    @Relationship(deleteRule: .cascade) var segments: [Segment] = [] // 부모(Song)가 삭제되면 연결된 자식(Segment)도 삭제, Segment와 1:N 관계

    init(id: Int, title: String, artist: String, arFileName: String, mrFileName: String, lyricsFileName: String, bpm: Int) {
        self.id = id
        self.title = title
        self.artist = artist
        self.arFileName = arFileName
        self.mrFileName = mrFileName
        self.lyricsFileName = lyricsFileName
        self.bpm = 100
    }
}

extension Song {
    static var preview: Song {
        Song(id: 1000, title: "내 여자 내 남자", artist: "배금성", arFileName: "1_ar.mp3", mrFileName: "1_mr.mp3", lyricsFileName: "1_lyrics", bpm: 100)
    }
}
