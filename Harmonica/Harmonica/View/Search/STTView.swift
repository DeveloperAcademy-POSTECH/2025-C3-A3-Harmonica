import SwiftUI
import Lottie

struct STTView {
  @State private var speechRecognizer = SpeechRecognizer()
  
  private let queryGenerateManager = QueryGenerateManager()
  private let musicManager = MusicManager()
  
  @State private var permissionMessage = ""
  @State private var isShowPermissionAlert = false
  @State private var isShowRecognizerAlert = false
  
  @State private var isShowMusicKitAlert = false
  @State private var musicPermisionMessage = ""
  
  @State private var isLoading = false
  @State private var item: Item?
  @State private var isShowSearchResult = false
  
  @State private var selectedSongID: String?
  @State private var navigateToDetail = false
  
  @State private var errorMessage: String?
  @State private var isShowErrorAlert = false
  
  let itemList = ["가수와 제목을 말해주세요", "지금 듣고 있어요"]
  
  @State private var currentIndex = 0
  let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
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
  
  private func resetRecognizer() {
    speechRecognizer.resetTranscript()
    speechRecognizer.stopTranscribing()
    speechRecognizer.onFinish = nil
  }
  
  private func searchMusic(query: String) {
    isLoading = true
    item = nil
    errorMessage = nil
    
    Task {
      do {
        let result = try await musicManager.searchTrack(query: query)
        item = result
        isShowSearchResult = true
      } catch {
        errorMessage = "노래 검색 중 에러가 발생했습니다.\n잠시 후에 다시 시도 해주세요."
        isShowErrorAlert = true
      }
      isLoading = false
    }
  }
  
  private func startSTT() {
    speechRecognizer.onFinish = { finalText in
      guard !finalText.isEmpty else { return }
      
      Task {
        do {
          let keyword = try await queryGenerateManager.generate(inputText: finalText)
          searchMusic(query: keyword)
          
        } catch {
          errorMessage = "에러가 발생했습니다.\n잠시 후에 다시 시도 해주세요."
          isShowErrorAlert = true
        }
      }
    }
    speechRecognizer.resetTranscript()
    speechRecognizer.startTranscribing()
  }
}

extension STTView: View {
  var body: some View {
    ZStack {
      
      LottieView2(animationName: "SongTitleSearchView")
      
      VStack {
        HStack {
          
          Button(action: {
            // 백버튼
          }) {
            Image(systemName: "arrow.left.circle.fill")
              .resizable()
              .frame(width: 80, height: 80)
              .fontWeight(.semibold)
              .foregroundStyle(Color(uiColor: UIColor(red: 0.15, green: 0.26, blue: 0.26, alpha: 1)))
          }
          
          Spacer()
          
          CustomTextFieldComponent(text: $speechRecognizer.transcript)
            .padding(.leading, -80)
          
          Spacer()
        }
        .padding(.top, 56)
        .padding(.horizontal, 56)
        
        
        Spacer()
        
        Text(itemList[currentIndex])
          .font(.system(size: 64, weight: .semibold))
          .frame(width: 657, alignment: .center)
          .onReceive(timer) { _ in
            if !isShowSearchResult {
              withAnimation {
                currentIndex = (currentIndex + 1) % itemList.count
              }
            }
          }
          .padding(.bottom, 80)
      }
      
    }
    .toolbarVisibility(.hidden, for: .navigationBar)
    .navigationDestination(isPresented: $navigateToDetail) {
      if let id = selectedSongID {
        NavigationTestView(id: id)
      }
    }
    .onAppear {
      selectedSongID = nil
      
      Task {
        guard await checkSTTPermission() else { return }
        guard await checkMusicPermission() else { return }
        
        startSTT()
      }
    }
    .onDisappear {
      resetRecognizer()
    }
    .customSheet(isPresented: $isShowSearchResult,onDismiss: {
      resetRecognizer()
      musicManager.stopPreview()
      
      if selectedSongID != nil {
        navigateToDetail = true
      } else {
        startSTT()
      }
    }) {
      SongSearchResultView(
        item: item,
        closeAction: {  self.isShowSearchResult = false },
        selectAction: {
          selectedSongID = $0
          self.isShowSearchResult = false
        },
        playAction: { musicManager.playPreview(for: $0)},
        resetActoin: { self.isShowSearchResult = false  })
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
        isShowRecognizerAlert = false
      }) {
        Text("확인")
      }
    } message: {
      Text(speechRecognizer.errorMessage ?? "")
    }
    .alert("오류 발생", isPresented: $isShowErrorAlert, actions: {
      Button(role: .cancel, action: { errorMessage = nil }) {
        Text("확인")
      }
    }, message: {
      Text(errorMessage ?? "알 수 없는 오류")
    })
  }
}


extension STTView {
  struct CustomTextFieldComponent {
    @State private var textWidth: CGFloat = 300
    @Binding var text: String
  }
}

extension STTView.CustomTextFieldComponent: View {
  var body: some View {
    VStack {
      TextField("", text: $text)
        .font(.system(size: 48))
        .foregroundStyle(Color(uiColor: UIColor(red: 0.6, green: 0.81, blue: 0.81, alpha: 1)))
        .padding(.horizontal, 67)
        .padding(.vertical, 4)
        .frame(width: textWidth, height: 80)
        .background(
          RoundedRectangle(cornerRadius: 42)
            .fill(Color(uiColor: UIColor(red: 0.15, green: 0.26, blue: 0.26, alpha: 1)))
        )
        .overlay(alignment: .leading) {
          Text(text)
            .font(.system(size: 48))
            .padding(.horizontal, 67)
            .padding(.vertical, 4)
            .fixedSize()
            .opacity(0)
            .background {
              GeometryReader {
                let size = $0.size
                
                Color.clear
                  .onChange(of: text) {
                    let calculatedWidth = max(300, min(900, size.width))
                    withAnimation(.easeInOut(duration: 0.2)) {
                      textWidth = calculatedWidth
                    }
                  }
              }
            }
        }
    }
  }
}

struct NavigationTestView: View {
  let id: String
  
  var body: some View {
    VStack {
      Text("노래: \(id)")
    }
  }
}

struct LottieView2: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopMode = loopMode
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}


#Preview {
  STTView()
}

