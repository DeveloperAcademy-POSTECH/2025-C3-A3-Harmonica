//
//  Lottie.swift
//  Harmonica
//
//  Created by 나현흠 on 6/8/25.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: animationName)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.loopMode = loopMode
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}


// 직접 뷰에 적용할 때는 LottieView(animationName: (json 파일 이름)
