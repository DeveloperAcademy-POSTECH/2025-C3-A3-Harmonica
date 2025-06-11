import SwiftUI
import Glur
import AVFoundation

struct MainView: View {
    @State private var isSTTPressed: Bool = false
    @State private var isShazamPressed: Bool = false
    @State private var showResultModal = false
    @State private var showSplash = true
    @StateObject private var navigationManager = NavigationManager()
    var body: some View {
        ZStack {
            NavigationStack(path: $navigationManager.path){
                HStack(spacing: 24) {
                    SongBox(SongName: "내 여자 내 남자", AlbumCover: Image("내 여자 내 남자 앨범 커버")){
                        showResultModal = true
                    }
                    SongBox(SongName: "나그네 고향", AlbumCover: Image("나그네고향"))
                    SongBox(SongName: "")
                }
                .padding(.bottom, 12)
                HStack {
                    ZStack {
                        Image(isShazamPressed ? "ShazamView_Pressed" : "ShazamView_Unpressed")
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isShazamPressed = true
                                playSound(sound: "ButtonSound", type: "mp3")
                            }
                            .onEnded { _ in
                                isShazamPressed = false
                                navigationManager.navigate(to: .Shazam)
                            }
                    )
                    .padding(.trailing, 14)
                    
                    
                    ZStack {
                        Image(isSTTPressed ? "STTSearchView_Pressed" : "STTSearchView_Unpressed")
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged{ _ in
                                isSTTPressed = true
                                playSound(sound: "ButtonSound", type: "mp3")
                            }
                            .onEnded{ _ in
                                isSTTPressed = false
                                navigationManager.navigate(to: .STT)
                            }
                    )
                    .onTapGesture {
                        playSound(sound: "ButtonSound", type: "mp3")
                    }
                }
                .navigationDestination(for: ViewType.self) { value in
                    switch value {
                    case .Shazam:
                        SongSearchView()
                            .environmentObject(navigationManager)
                    case .STT:
                        STTView()
                            .environmentObject(navigationManager)
                    case .Practice:
                        KaraokeLyricView(songInfo: .preview)
                            .environmentObject(navigationManager)
                    case .End:
                        PracticeCompleteView()
                            .environmentObject(navigationManager)
                    case .Loading:
                        LoadingView()
                            .environmentObject(navigationManager)
                    }
                }
            }
            .environmentObject(navigationManager)
            
            if showSplash {
                            SplashView()
                                .transition(.opacity)
                                .zIndex(1) // 메인보다 위로 올림
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            showSplash = false
                                        }
                                    }
                                }
                        }
            ZStack {
                if showResultModal {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            playSound(sound: "ButtonSound", type: "mp3")
                            showResultModal = false
                        }
                    
                    HistoryResultView(isPresented: $showResultModal)
                        .environmentObject(navigationManager)
                        .frame(width: 1022, height: 687)
                        .background(Color.white)
                        .cornerRadius(40)
                        .shadow(radius: 10)
                        .transition(.scale)
                }
            }
        }
    }
}


#Preview {
    //    SongBox(SongName: "나그네 고향")
    MainView()
}
