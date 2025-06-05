import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            HStack {
                // 화면 좌측 [불렀던 곡(히스토리)] 세로 스크롤뷰
                HistoryView()
                // 화면 우측 [App이름 로고]와 [두가지 방식의 노래검색 버튼]
                VStack {
                    Text("harmonica")
                        .font(Font.custom("Pacifico", size: 64))
                        .foregroundColor(Color(red: 0.49, green: 0, blue: 0))
                    Spacer()
                    // [음악인식 검색뷰(듀이) 이동버튼]
                    NavigationLink(destination: SongSearchView()) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 484, height: 274)
                                .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                                .cornerRadius(20)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 460, height: 250)
                                .background(Color(red: 0.82, green: 0.8, blue: 0.77))
                                .cornerRadius(30)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 426, height: 220)
                                .background(Color(red: 0.92, green: 0.9, blue: 0.88))
                                .cornerRadius(100)
                                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .inset(by: 2.5)
                                        .stroke(.white, lineWidth: 5)
                                )
                            Text("음악 들려줘서 \n 찾기")
                                .font(
                                    Font.custom("Pretendard JP", size: 55)
                                        .weight(.bold)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                        }
                    }
                    // [음성노래제목 검색뷰(루크) 이동버튼]
                    NavigationLink(destination: STTView()) {
                        ZStack{
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 484, height: 274)
                                .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                                .cornerRadius(20)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 460, height: 250)
                                .background(Color(red: 0.82, green: 0.8, blue: 0.77))
                                .cornerRadius(30)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 426, height: 220)
                                .background(Color(red: 0.92, green: 0.9, blue: 0.88))
                                .cornerRadius(100)
                                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .inset(by: 2.5)
                                        .stroke(.white, lineWidth: 5)
                                )
                            Text("제목 말해서 \n 찾기")
                                .font(
                                    Font.custom("Pretendard JP", size: 55)
                                        .weight(.bold)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .padding()
        }
    }
}
