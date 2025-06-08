//
//  PracticeCompleteView.swift
//  Harmonica
//
//  Created by 나현흠 on 6/7/25.
//

import SwiftUI

struct PracticeCompleteView: View {
    var index: Int = Int.random(in: 0..<5)
    var CheeringText: [String:String] = [
    "할머니, 오늘도 정말 멋진 무대였어요!":"다음 연습도 기대할게요~!",
    "오늘도 열심히 연습하셨네요!":"덕분에 저도 즐거웠어요. 또 함께해요!",
    "이렇게 연습 잘하시면 금방 노래왕 되시겠어요!":"다음에 또 만나요!",
    "노래가 점점 더 빛이 나네요!":"다음에도 꼭 오셔서 멋진 무대 보여주세요~!",
    "오늘도 고생 많으셨어요!":"다음에 더 멋진 목소리 들려주세요, 화이팅!",
    "노래 정말 잘 부르시는 걸요?":"가수로 데뷔해도 되겠어요!❤️"]
    
    // TODO: NavigationStack 어떻게 조작해야 할 지 학습 후 적용
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Image("Star")
                .blur(radius: 25)
                .opacity(0.8)
            Image("Star")
                .blur(radius: 50)
                .opacity(0.5)
            Image("Star")
                .blur(radius: 77.4)
                .opacity(0.35)
            VStack{
                Text(Array(CheeringText.keys)[index])
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                
                Text(Array(CheeringText.values)[index])
                    .font(.system(size: 48, weight: .regular, design: .default))
                    .foregroundColor(.black)
                    .padding(.bottom, 140)
                
                LottieView(animationName: "happy")
                    .padding(.bottom, 30)
                    .frame(width: 300, height: 271)
                
                
                //TODO: 곡 끝까지 재생 후 종료 이외에 연습 중 종료는 버튼 어떻게 표시할 지 확인 후 텍스트 적용
                HStack(spacing: 50) {
                    Button(action: {
                        // TODO: PracticeView 진행상황 초기화하고 PracticeView로 이동
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "505050"))
                            Text("처음부터 다시")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "505050"))
                        }
                        .frame(width: 416, height: 100)
                        .background(Color(hex: "DDDDDD"))
                        .cornerRadius(16)
                    }
                    .frame(width: 416, height: 100.0)
                    
                    Button(action: {
                        path.removeLast(path.count)
                    }) {
                        HStack {
                            Image(systemName: "power.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "005F61"))
                            Text("노래연습 종료")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "005F61"))
                        }
                        .frame(width: 416, height: 100)
                        .background(Color(hex: "C8E9EA"))
                        .cornerRadius(16)
                    }
                }
            }
        }
    }
}

#Preview {
    PracticeCompleteView(path: .constant(NavigationPath()))
}
