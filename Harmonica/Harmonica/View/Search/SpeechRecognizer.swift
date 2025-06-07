import Foundation
import AVFoundation
import Speech
import Observation

@Observable
final class SpeechRecognizer {
  
  enum RecognizerError: Error {
    case nilRecognizer
    case notAuthorizedToRecognize
    case notPermittedToRecord
    case recognizerIsUnavailable
    
    var message: String {
      switch self {
      case .nilRecognizer:
        return "음성 인식기를 초기화할 수 없습니다.\n앱을 종료 후 다시 실행해주세요."
      case .notAuthorizedToRecognize:
        return "음성 인식 권한이 허용되지 않았습니다.\n설정 앱에서 권한을 허용해주세요."
      case .notPermittedToRecord:
        return "마이크 접근 권한이 허용되지 않았습니다.\n설정 앱에서 권한을 허용해주세요."
      case .recognizerIsUnavailable:
        return "현재 음성 인식 기능을 사용할 수 없습니다.\n네트워크 연결을 확인하거나 잠시 후 다시 시도해주세요."
      }
    }
  }
  
  var transcript: String = ""
  var errorMessage: String?
  var isRecording = false
  
  private var audioEngine: AVAudioEngine?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
  
  private var isStopping = false
  
  private var timer: Timer?
  
  var onFinish: ((String) -> Void)?
  
  init() { }
  
  func startTranscribing() {
    isRecording = true
    isStopping = false
    transcribe()
  }
  
  func stopTranscribing() {
    isRecording = false
    isStopping = true
    timer?.invalidate()
    timer = nil
    onFinish?(transcript)
    reset()
  }
  
  func resetTranscript() {
    transcript = ""
    reset()
  }
  
  private func reset() {
    task?.cancel()
    audioEngine?.stop()
    audioEngine?.inputNode.removeTap(onBus: 0)
    audioEngine = nil
    request = nil
    task = nil
  }
  
  private func transcribe() {
    guard let recognizer, recognizer.isAvailable else {
      transcribe(RecognizerError.recognizerIsUnavailable)
      return
    }
    
    do {
      let (engine, request) = try Self.prepareEngine()
      self.audioEngine = engine
      self.request = request
      
      self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
        self?.recognitionHandler(audioEngine: engine, result: result, error: error)
      })
    } catch {
      reset()
      transcribe(error)
    }
  }
  
  private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
    let audioEngine = AVAudioEngine()
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.shouldReportPartialResults = true
    request.addsPunctuation = true
    
    let session = AVAudioSession.sharedInstance()
    try session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
    try session.setActive(true, options: .notifyOthersOnDeactivation)
    
    let inputNode = audioEngine.inputNode
    let format = inputNode.outputFormat(forBus: 0)
    
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
      request.append(buffer)
    }
    
    audioEngine.prepare()
    try audioEngine.start()
    
    return (audioEngine, request)
  }
  
  private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
    
    guard !isStopping else { return }
    
    if let result {
      let newText = result.bestTranscription.formattedString
      
      if result.isFinal {
        transcribe(newText)
        stopTranscribing()
        return
      }
      
      if !newText.isEmpty && newText.count >= transcript.count {
        transcribe(newText)
        startTimer()
      }
    }
    
    if let error {
      transcribe(error)
    }
  }
  
  private func transcribe(_ message: String) {
    Task { @MainActor in
      transcript = message
    }
  }
  
  private func transcribe(_ error: Error) {
    let message: String
    if let recognizerError = error as? RecognizerError {
      message = recognizerError.message
    } else {
      message = error.localizedDescription
    }
    
    Task { @MainActor in
      errorMessage = message
    }
  }
  
  private func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
      self?.stopTranscribing()
    }
  }
}

