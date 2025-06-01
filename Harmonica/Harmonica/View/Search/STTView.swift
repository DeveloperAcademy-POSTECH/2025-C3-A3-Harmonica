import SwiftUI

struct STTView {
  @State private var permissionMessage = ""
  @State private var isShowPermissionAlert = false
  
  @State private var speechRecognizer = SpeechRecognizer()
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
      
      HStack {
        Button(action: {
          Task {
            if await checkSTTPermission() {
              startSpeechRecognition()
            }
          }
        }) {
          Text("Start")
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 8))
        }
        
        Button(action: { stopSpeechRecognition() }) {
          Text("Stop")
            .padding()
            .background(Color.red)
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 8))
        }
      }
    }
    .onAppear {
      Task {
        _ = await checkSTTPermission()
      }
    }
    .onDisappear {
      stopSpeechRecognition()
      resetSpeechRecognition()
    }
    .alert("권한이 필요합니다", isPresented: $isShowPermissionAlert) {
      
      Button(action: { isShowPermissionAlert = false }) {
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
  }
}
