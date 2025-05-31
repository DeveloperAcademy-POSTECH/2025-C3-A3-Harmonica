import SwiftUI

struct SongSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack() {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    // 뒤로가기 버튼 이미지
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 110)
                            .background(Color(red: 0.34, green: 0.34, blue: 0.34))
                            .cornerRadius(20)
                        Image("Ellipse 11")
                            .frame(width: 120, height: 82)
                            .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                        Text("이전")
                            .font(
                                Font.custom("SF Pro", size: 48)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.92, green: 0.91, blue: 0.87))
                    }
                }
                .padding()
                Spacer()
            }
            Spacer()
            // 대충 음악을 듣고 있는 이미지
            ZStack{
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(width: 260, height: 260)
                  .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                  .cornerRadius(260)
                  .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                Text("􀞉")
                  .font(
                    Font.custom("SF Pro", size: 200)
                      .weight(.medium)
                  )
                  .multilineTextAlignment(.center)
                  .foregroundColor(Color(red: 0.92, green: 0.9, blue: 0.88))
                  .symbolEffect(.breathe)
            }
            Text("노래를 들려주세요 ")
              .font(
                Font.custom("SF Pro", size: 64)
                  .weight(.medium)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
              .padding()
            Text("지금 들려주세요 듣고있어요")
              .font(
                Font.custom("SF Pro", size: 48)
                  .weight(.medium)
              )
              .multilineTextAlignment(.center)
              .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
            Spacer()
        }
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨김
    }
}
