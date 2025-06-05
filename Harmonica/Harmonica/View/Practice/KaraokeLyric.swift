//
//  KaraokeLyric.swift
//  HarmonyKaraoke
//
//  Created by 나현흠 on 6/3/25.
//

import Foundation

/// 한 소절의 가사와 그에 해당하는 타이밍 정보를 나타내는 모델
struct LyricLine: Decodable{
    let text: String
    let timings: [Double]

    /// 각 글자별 지속 시간을 계산해 반환
    var characterDurations: [(String, Double)] {
        let chars = Array(text).map { String($0) }
        let durations = zip(timings, timings.dropFirst()).map { $1 - $0 }
        return Array(zip(chars, durations))
    }
}

struct JSONLyricLine: Decodable {
    let index: Int
    let Lyric: String
    let timingArray: [Double]
}

/// 전체 가사 데이터를 제공하는 클래스
class LyricProvider {
    /// 순서가 중요한 가사와 타이밍 배열
    private let orderedLyrics: [(String, [Double])]

    init(jsonFileName: String) {
        if let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let parsed = parseOrderedLyrics(from: data) {
            self.orderedLyrics = parsed
        } else {
            self.orderedLyrics = []
        }
    }

    /// 가사를 순서대로 반환
    var lyricLines: [LyricLine] {
        orderedLyrics.map { LyricLine(text: $0.0, timings: $0.1) }
    }
}

func parseOrderedLyrics(from data: Data) -> [(String, [Double])]? {
    do {
        let decoder = JSONDecoder()
        let lines = try decoder.decode([JSONLyricLine].self, from: data)
        
        // index 기준으로 정렬 후 필요한 형태로 매핑
        let orderedLyrics = lines
            .sorted(by: { $0.index < $1.index })
            .map { ($0.Lyric, $0.timingArray) }

        return orderedLyrics
    } catch {
        print("Parsing error: \(error)")
        return nil
    }
}
