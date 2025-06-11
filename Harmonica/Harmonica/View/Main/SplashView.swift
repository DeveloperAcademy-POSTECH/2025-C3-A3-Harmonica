//
//  LoadingView.swift
//  Harmonica
//
//  Created by 나현흠 on 6/9/25.
//

import SwiftUI

struct SplashView: View {
    @State var isFirstVisit: Bool = true
    
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
                LottieView(animationName: "hello")
                    .frame(width: 300, height: 271)
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden()
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                navigationManager.poptoRoot()
//            }
//        }
    }
}
