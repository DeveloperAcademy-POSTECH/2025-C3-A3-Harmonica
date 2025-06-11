import Foundation
import MusicKit
import AVFoundation

struct Item: Identifiable, Equatable, Hashable {
  let id: String
  let title: String
  let artist: String
  let previewURL: URL?
  let artworkURL: URL?
  
  init(
    id: String,
    title: String,
    artist: String,
    previewURL: URL? = nil,
    artworkURL: URL? = nil)
  {
    self.id = id
    self.title = title
    self.artist = artist
    self.previewURL = previewURL
    self.artworkURL = artworkURL
  }
}


final class MusicManager {
  private var player: AVPlayer?
}

extension MusicManager {
  func searchTrack(query: String) async throws -> Item? {
    let request = MusicCatalogSearchRequest(term: query, types: [Song.self])

    guard query != "" else { return nil }
   
    do {
      let response = try await request.response()
      
      guard let song = response.songs.first else { return nil }
      
      return .init(
        id: song.id.rawValue,
        title: song.title,
        artist: song.artistName,
        previewURL: song.previewAssets?.first?.url,
        artworkURL: song.artwork?.url(width: 270, height: 270))
      
    } catch {
      throw error
    }
  }
  
  func playPreview(for url: URL) {
    player = AVPlayer(url: url)
    player?.play()
  }
  
  func stopPreview() {
    player?.pause()
    player = nil
  }
}

