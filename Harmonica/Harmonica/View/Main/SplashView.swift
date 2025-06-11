//
//  LoadingView.swift
//  Harmonica
//
//  Created by 나현흠 on 6/9/25.
//

//import SwiftUI
//
//struct SplashView: View {
//    @EnvironmentObject var navigationManager: NavigationManager
//    var index: Int = Int.random(in: 0..<5)
//    
//    @State var isFirstVisit: Bool = true
//    
//    // TODO: NavigationStack 어떻게 조작해야 할 지 학습 후 적용
//    
//    var body: some View {
//        ZStack {
//            Image("Star")
//                .blur(radius: 25)
//                .opacity(0.8)
//            Image("Star")
//                .blur(radius: 50)
//                .opacity(0.5)
//            Image("Star")
//                .blur(radius: 77.4)
//                .opacity(0.35)
//            VStack{
//                
//                LottieView(animationName: "hello")
//                    .padding(.bottom, 30)
//                    .frame(width: 300, height: 271)
//            }
//        }
//        .navigationBarBackButtonHidden()
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                navigationManager.poptoRoot()
//            }
//        }
//    }
//}
