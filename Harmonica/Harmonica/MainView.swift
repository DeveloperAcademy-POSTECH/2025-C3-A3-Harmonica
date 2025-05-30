import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 808, height: 808)
                        .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                        .cornerRadius(20)
                    VStack{
                        HStack {
                            // 루크가 작업한 "제목으로 찾기" 뷰 추가하기 필요
                            // NavigationLink(destination: ) {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 368, height: 368)
                                    .background(Color(red: 0.82, green: 0.8, blue: 0.77))
                                    .cornerRadius(30)
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 292, height: 292)
                                    .background(Color(red: 0.92, green: 0.9, blue: 0.88))
                                    .cornerRadius(30)
                                    .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .inset(by: 2.5)
                                            .stroke(.white, lineWidth: 5)
                                    )
                                Text("제목으로 찾기")
                                    .font(
                                        Font.custom("SF Pro", size: 64)
                                            .weight(.medium)
                                    )
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                            }
                            NavigationLink(destination: SongSearchView()) {
                                ZStack{
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 368, height: 368)
                                        .background(Color(red: 0.82, green: 0.8, blue: 0.77))
                                        .cornerRadius(30)
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 292, height: 292)
                                        .background(Color(red: 0.92, green: 0.9, blue: 0.88))
                                        .cornerRadius(30)
                                        .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 30)
                                                .inset(by: 2.5)
                                                .stroke(.white, lineWidth: 5)
                                        )
                                    Text("노래로 찾기")
                                        .font(
                                            Font.custom("SF Pro", size: 64)
                                                .weight(.medium)
                                        )
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                                }
                            }
                            
                        }
                        NavigationLink(destination: HistoryView()) {
                            ZStack{
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 759, height: 368)
                                    .background(Color(red: 0.75, green: 0.75, blue: 0.75))
                                
                                    .cornerRadius(100)
                                
                                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 670, height: 292)
                                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                
                                    .cornerRadius(100)
                                
                                    .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 100)
                                            .inset(by: 2.5)
                                            .stroke(.white, lineWidth: 5)
                                        
                                    )
                                Text("불렀던 곡")
                                    .font(
                                        Font.custom("SF Pro", size: 64)
                                            .weight(.medium)
                                    )
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
