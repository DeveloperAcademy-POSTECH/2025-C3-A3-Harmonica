//
//  SongManager.swift
//  Harmonica
//
//  Created by 나현흠 on 6/11/25.
//

import AVFoundation
import Foundation
import SwiftUI

var audioPlayer: AVAudioPlayer?

func playSound(sound: String, type: String) {
  if let path = Bundle.main.path(forResource: sound, ofType: type) {
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
      audioPlayer?.play()
    } catch {
      print("Could not find and play the sound file.")
    }
  }
}
