import SwiftUI

struct STTView {
  @State private var permissionMessage = ""
  @State private var isShowPermissionAlert = false
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
}

extension STTView: View {
  var body: some View {
    VStack {
      Text("Test")
    }
    .onAppear {
      Task {
        _ = await checkSTTPermission()
      }
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
