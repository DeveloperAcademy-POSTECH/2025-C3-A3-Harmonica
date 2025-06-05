import AVFoundation
import Speech

enum MicPermissionStatus {
  case granted
  case denied
  case undetermined
}

enum SpeechPermissionStatus {
  case authorized
  case denied
  case restricted
  case notDetermined
}

struct PermissionManager {
  
  static func requestMicPermission() async -> MicPermissionStatus {
    let permission = AVAudioApplication.shared.recordPermission
    switch permission {
    case .granted:
      return .granted
    case .denied:
      return .denied
    case .undetermined:
      return await withCheckedContinuation { continuation in
        AVAudioApplication.requestRecordPermission { granted in
          continuation.resume(returning: granted ? .granted : .denied)
        }
      }
    @unknown default:
      return .undetermined
    }
  }
  
  static func requestSpeechPermission() async -> SpeechPermissionStatus {
    await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        switch status {
        case .authorized:
          continuation.resume(returning: .authorized)
        case .denied:
          continuation.resume(returning: .denied)
        case .restricted:
          continuation.resume(returning: .restricted)
        case .notDetermined:
          continuation.resume(returning: .notDetermined)
        @unknown default:
          continuation.resume(returning: .notDetermined)
        }
      }
    }
  }
  
  static func requestSTTPermissions() async -> (MicPermissionStatus, SpeechPermissionStatus) {
    let mic = await requestMicPermission()
    let speech = await requestSpeechPermission()
    return  (mic, speech)
  }
}
