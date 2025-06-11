import Foundation
import SwiftData

@MainActor
class SongDataManager: ObservableObject {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // 기본 곡 정보 저장
    func loadDefaultSongsIfNeeded() {
        let descriptor = FetchDescriptor<SongInfo>()
        let existingSongs = (try? modelContext.fetch(descriptor)) ?? []
        
        if existingSongs.isEmpty {
            for song in SongInfo.defaultSongs {
                modelContext.insert(song)
            }
            
            do {
                try modelContext.save()
                print("Default Song Load Completed")
            } catch {
                print("FAIL default song load: \(error)")
            }
        }
    }
    
    // 곡 추가
    func addSong(_ song: SongInfo) {
        modelContext.insert(song)
        try? modelContext.save()
    }
    
    // 곡 삭제
    func deleteSong(_ song: SongInfo) {
        modelContext.delete(song)
        try? modelContext.save()
    }
    
    // 모든 곡 가져오기
    func getAllSongs() -> [SongInfo] {
        let descriptor = FetchDescriptor<SongInfo>(sortBy: [SortDescriptor(\.title)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
