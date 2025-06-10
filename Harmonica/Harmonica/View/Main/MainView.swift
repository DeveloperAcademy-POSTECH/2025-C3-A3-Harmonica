import SwiftUI
import Glur

struct MainView: View {
    @State private var isSTTPressed: Bool = false
    @State private var isShazamPressed: Bool = false
    @State private var path = NavigationPath()
    var body: some View {
//        NavigationStack(path: $path){
        NavigationStack{
            HStack(spacing: 24) {
                SongBox(SongName: "나그네 고향", AlbumCover: Image("나그네고향"))
                SongBox(SongName: "내 여자 내 남자", AlbumCover: Image("내 여자 내 남자 앨범 커버"))
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
//                            path.append("shazam")
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
//                            path.append("STT")
                        }
                )
            }
//            .navigationDestination(for: String.self) { value in
//                if value == "shazam" {
//                    SongSearchView()
//                }
//                else if value == "STT" {
//                    STTView()
//                }
//            }
        }
    }
}

struct SongBox:View {
    @State var SongName:String = ""
    @State var AlbumCover:Image?
    var body: some View {
        Button(action: {}){
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

#Preview {
    //    SongBox(SongName: "나그네 고향")
    MainView()
}
