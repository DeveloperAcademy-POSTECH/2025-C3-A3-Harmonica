import Foundation
import SwiftData

@Model
class SongInfo {
    @Attribute(.unique) var id: Int
    var title: String
    var artist: String
    var arFileName: String
    var mrFileName: String
    var lyricsFileName: String
    var bpm: Int
    var timeSignatureTop: Int
    var timeSignatureBottom: Int

    init(id: Int, title: String, artist: String, arFileName: String, mrFileName: String, lyricsFileName: String, bpm: Int, timeSignatureTop: Int, timeSignatureBottom: Int) {
        self.id = id
        self.title = title
        self.artist = artist
        self.arFileName = arFileName
        self.mrFileName = mrFileName
        self.lyricsFileName = lyricsFileName
        self.bpm = bpm
        self.timeSignatureTop = timeSignatureTop
        self.timeSignatureBottom = timeSignatureBottom
    }
}

// MARK: - Preview 및 기본 데이터
extension SongInfo {
    static var preview: SongInfo {
        SongInfo(id: 1, title: "내 여자 내 남자", artist: "배금성", arFileName: "1_ar.mp3", mrFileName: "1_mr.mp3", lyricsFileName: "1_lyrics", bpm: 143, timeSignatureTop: 4, timeSignatureBottom: 4)
    }
    
    // 기본 곡 정보들
    static var defaultSongs: [SongInfo] {
        return [
            SongInfo(id: 1641943955, title: "내 여자 내 남자", artist: "배금성", arFileName: "1_ar.mp3", mrFileName: "1_mr.mp3", lyricsFileName: "1_lyrics", bpm: 143, timeSignatureTop: 4, timeSignatureBottom: 4),
            SongInfo(id: 1759969510, title: "내 여자 내 남자", artist: "배금성", arFileName: "1_ar.mp3", mrFileName: "1_mr.mp3", lyricsFileName: "1_lyrics", bpm: 143, timeSignatureTop: 4, timeSignatureBottom: 4)
        ]
    }
}
