//
//  LoadingView.swift
//  Harmonica
//
//  Created by 나현흠 on 6/9/25.
//

import SwiftUI

import SwiftUI

struct LoadingView: View {
    var index: Int = Int.random(in: 0..<5)
    var CheeringText: [String:String] = [
    "오늘도 멋진 노래 한 곡 불러봐요!":"할머니 최고에요!",
    "노래 실력이 쑥쑥!":"오늘도 함께 연습해봐요!",
    "연습할수록 실력이 늘어요!":"자신감을 갖고 도전해봐요!",
    "할머니의 목소리를 기다리고 있었어요!":"즐겁게 연습해요~!",
    "오늘도 멋진 노래 한 소절, 기대할게요!":"할머니, 파이팅!"]
    
    @State var isFirstVisit: Bool = true
    
    // TODO: NavigationStack 어떻게 조작해야 할 지 학습 후 적용
    
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
                Text(isFirstVisit ? "이 노래를 완벽하게 부르는 그날까지!" : Array(CheeringText.keys)[index])
                    .font(.system(size: 48, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .padding(.top, 60)
                
                Text(isFirstVisit ? "우리 한 번 파이팅 해봐요!❤️" : Array(CheeringText.values)[index])
                    .font(.system(size: 48, weight: .regular, design: .default))
                    .foregroundColor(.black)
                    .padding(.bottom, 140)
                
                LottieView(animationName: "happy")
                    .padding(.bottom, 30)
                    .frame(width: 300, height: 271)
            }
        }
    }
}

#Preview {
    LoadingView()
}
