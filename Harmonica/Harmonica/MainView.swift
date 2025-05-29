import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // 루크가 작업한 "제목으로 찾기" 뷰 추가하기 필요
                    
                    NavigationLink(destination: SongSearchView()) {
                        Text("노래로 찾기")
                            .font(.system(size: 48))
                            .foregroundColor(.black)
                    }
                }

                NavigationLink(destination: HistoryView()) {
                    Text("불렀던 곡")
                        .font(.system(size: 48))
                        .foregroundColor(.black)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
