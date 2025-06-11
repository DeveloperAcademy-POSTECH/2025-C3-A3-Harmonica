import SwiftUI
import Glur

struct MainView: View {
    @State private var isSTTPressed: Bool = false
    @State private var isShazamPressed: Bool = false
    @State private var showResultModal = false
    @StateObject private var navigationManager = NavigationManager()
    var body: some View {
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
                        }
                        .onEnded{ _ in
                            isSTTPressed = false
                            navigationManager.navigate(to: .STT)
                        }
                )
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
                            }
                        }
        }
        .environmentObject(navigationManager)
        .sheet(isPresented: $showResultModal) {
            ZStack {
                HistoryResultView(isPresented: $showResultModal)
                    .environmentObject(navigationManager)
            }
            .frame(width: 1022, height: 687)
            .cornerRadius(60)
        }
    }
}

struct SongBox:View {
    @State var SongName:String = ""
    @State var AlbumCover:Image?
    var action: () -> Void = {}
    var body: some View {
        Button(action: action){
            ZStack(alignment: .bottomLeading){
                if let albumImage = AlbumCover {
                    albumImage
                        .resizable()
                        .scaledToFit()
                        .glur(radius: 6.0,
                              offset: 0,
                              interpolation: 0.8,
                              direction: .down
                        )
                        .cornerRadius(16)
                        .frame(width: 385, height: 269)
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2E4E4E").opacity(0.7), Color(hex: "254142")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 385, height: 269)
                Text("\(SongName)")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .padding(.leading,6)
                    .padding(.bottom, 4)
            }
        }
    }
}

struct HistoryResultView: View {
    @Binding var isPresented: Bool
    @State private var selectedSongIndex: Int? = nil
    @State private var isPlaying: Bool = false
    @State private var isLoading: Bool = false
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
            VStack {
                VStack(spacing: 56) {
                  Text("찾으시던 노래가 맞으신가요?")
                    .font(.system(size: 48, weight: .semibold))
                    HStack(spacing: 25) {
                      Image("내 여자 내 남자 커버")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 270, height: 270)
                        .clipShape(.rect(cornerRadius: 30))
                      
                      VStack(alignment: .leading) {
                        Text("배금성")
                        Text("내 여자 내 남자")
                      }
                      .font(.system(size: 64, weight: .bold))
                    }
                  }
                  HStack(spacing: 50) {
                    Button(action: {
                        isPresented = false
                    }) {
                      HStack {
                        Image(systemName: "power.circle.fill")
                          .font(.system(size: 48))
                          .foregroundColor(Color(hex: "505050"))
                        Text("처음으로 가기")
                          .font(.system(size: 48, weight: .bold))
                          .foregroundColor(Color(hex: "505050"))
                      }
                      .frame(width: 416, height: 100)
                      .background(Color(hex: "DDDDDD"))
                      .cornerRadius(16)
                    }
                    .frame(width: 416, height: 100.0)
                    
                    Button(action: {
                        isPresented = false
                        navigationManager.navigate(to: .Practice)
                    }) {
                      HStack {
                        Image(systemName: "music.quarternote.3")
                          .font(.system(size: 48))
                          .foregroundColor(Color(hex: "005F61"))
                        Text("노래 연습 시작")
                          .font(.system(size: 48, weight: .bold))
                          .foregroundColor(Color(hex: "005F61"))
                      }
                        
                      .frame(width: 416, height: 100)
                      .background(Color(hex: "C8E9EA"))
                      .cornerRadius(16)
                    }
                      
                  }
                }
                .padding(.vertical, 10)
                .navigationBarHidden(true)
        }
    }


#Preview {
    //    SongBox(SongName: "나그네 고향")
    MainView()
}
