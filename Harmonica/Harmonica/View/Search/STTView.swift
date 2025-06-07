import SwiftUI

struct STTView {
  @State private var speechRecognizer = SpeechRecognizer()
  
  private let queryGenerateManager = QueryGenerateManager()
  
  @State private var permissionMessage = ""
  @State private var isShowPermissionAlert = false
  @State private var isShowRecognizerAlert = false
  
  @State private var searchKeyword = ""
  
  @State private var isShowQueryGenerateAlert = false
  @State private var queryGenerateMessage = ""
  
  @State private var isShowMusicKitAlert = false
  @State private var musicPermisionMessage = ""
}

extension STTView {
  private func checkSTTPermission() async -> Bool {
    let status = await PermissionManager.requestSTTPermissions()
    switch (status.0, status.1) {
    case (.granted, .authorized):
      return true
    case (.denied, _):
      permissionMessage = "마이크 접근 권한이 필요합니다.\n설정 앱에서 허용해주세요."
    case (_, .denied), (_, .restricted):
      permissionMessage = "음성 인식 권한이 필요합니다.\n설정 앱에서 허용해주세요."
    case (.undetermined, _), (_, .notDetermined):
      permissionMessage = "권한 요청이 아직 완료되지 않았습니다.\n다시 시도해주세요."
    }
    
    isShowPermissionAlert = true
    return false
  }
  
  private func checkMusicPermission() async -> Bool {
    let status = await PermissionManager.requestMusicPermission()
    switch status {
    case .authorized:
      return true
    case .denied, .restricted:
      musicPermisionMessage = "Apple Music 접근 권한이 필요합니다.\n설정 앱에서 허용해주세요."
    case .notDetermined:
      musicPermisionMessage = "Apple Music 권한 요청이 완료되지 않았습니다.\n다시 시도해주세요."
    }
    
    isShowMusicKitAlert = true
    return false
  }
  
  
  private func startSpeechRecognition() {
    speechRecognizer.resetTranscript()
    speechRecognizer.startTranscribing()
  }
  
  private func resetSpeechRecognition() {
    speechRecognizer.resetTranscript()
  }
  
  private func stopSpeechRecognition() {
    speechRecognizer.stopTranscribing()
  }
  
}

extension STTView: View {
  var body: some View {
    VStack {
      Text("Speech To Text")
        .font(.title)
        .padding()
        .foregroundStyle(speechRecognizer.isRecording ? .black : .gray.opacity(0.3))
      
      TextField("", text: $speechRecognizer.transcript)
        .padding()
        .frame(height: 50)
        .border(.black, width: 1)
        .padding()
      
      Divider()
      
      Text(searchKeyword)
    }
    .onAppear {
      Task {
        speechRecognizer.onFinish = nil
        speechRecognizer.onFinish = { finalText in
          guard !finalText.isEmpty else { return }
          
          Task {
            do {
              let keyword = try await queryGenerateManager.generate(inputText: finalText)
              searchKeyword = keyword
            } catch {
              queryGenerateMessage = error.localizedDescription
              isShowQueryGenerateAlert = true
            }
          }
        }
        
        guard await checkSTTPermission() else { return }
        guard await checkMusicPermission() else { return }
        
        startSpeechRecognition()
        
      }
    }
    .onDisappear {
      stopSpeechRecognition()
      resetSpeechRecognition()
      speechRecognizer.onFinish = nil
    }
    .onChange(of: speechRecognizer.errorMessage) { _, new in
      guard new != nil else { return }
      isShowRecognizerAlert = true
    }

    .alert("권한이 필요합니다", isPresented: $isShowPermissionAlert) {
      Button(action: {
        isShowPermissionAlert = false
        permissionMessage = ""
      }) {
        Text("취소")
      }
      
      Button(action: {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }) {
        Text("설정으로 이동")
      }
      
    } message: {
      Text(permissionMessage)
    }
    .alert("애플 뮤직 권한 요청", isPresented: $isShowMusicKitAlert) {
      Button(action: {
        isShowMusicKitAlert = false
        musicPermisionMessage = ""
      }) {
        Text("취소")
      }
      
      Button(action: {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }) {
        Text("설정으로 이동")
      }
      
    } message: {
      Text(musicPermisionMessage)
    }
    .alert("음성 인식 오류", isPresented: $isShowRecognizerAlert) {
      Button(action: {
        speechRecognizer.errorMessage = nil
        isShowPermissionAlert = false
      }) {
        Text("확인")
      }
    } message: {
      Text(speechRecognizer.errorMessage ?? "")
    }
    .alert("쿼리 생성 오류", isPresented: $isShowQueryGenerateAlert) {
      Button(action: {
        queryGenerateMessage = ""
        isShowQueryGenerateAlert = false
      }) {
        Text("확인")
      }
    } message: {
      Text(queryGenerateMessage)
    }
  }
}
