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
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundColor(.blue)
                    Text("이전")
                        .foregroundColor(.blue)
                }
                .padding()
                Spacer()
            }
            Spacer()
            // 대충 음악을 듣고 있다는 이미지
            Text("노래를 들려주세요")
                .font(.system(size: 48))
                .foregroundColor(.black)
            Text("지금 듣고 있어요")
                .font(.system(size: 48))
                .foregroundColor(.black)
            Spacer()
        }
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨김
    }
}
