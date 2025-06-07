import SwiftUI

struct MainView: View {
    @State private var isSTTPressed: Bool = false
    @State private var isShazamPressed: Bool = false
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path){
            HStack(spacing: 24) {
                SongBox(SongName: "나그네 고향", AlbumCover: Image("나그네고향"))
                SongBox(SongName: "사내답게")
                SongBox(SongName: "내 여자 내 남자")
            }
            .padding(.bottom, 12)
            HStack {
                ZStack {
                    Image(isShazamPressed ? "ShazamView_Pressed" : "ShazamView_UnPressed")
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            isShazamPressed = true
                        }
                        .onEnded { _ in
                            isShazamPressed = false
                            path.append("shazam")
                        }
                )
                .padding(.trailing, 14)
                

                ZStack {
                    Image(isSTTPressed ? "STTSearchView_Pressed" : "STTSearchView_UnPressed")
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ _ in
                                isSTTPressed = true
                        }
                        .onEnded{ _ in
                            isSTTPressed = false
                            path.append("STT")
                        }
                )
            }
            .navigationDestination(for: String.self) { value in
                if value == "shazam" {
                    SongSearchView()
                }
                else if value == "STT" {
                    STTView()
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // "#" 기호 제거
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
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
                        .scaledToFill()
                        .blur(radius:2)
                        .mask(
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .black]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            //블러 처리 하는 부분...인데 블러 굳이 필요할까 싶긴 한데...페퍼가 하라니까 한 거긴 한데 테크 눈에는 없는게 나아보이기도...
                        )
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
