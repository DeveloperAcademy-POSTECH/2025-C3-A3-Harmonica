//
//  NavigationManager.swift
//  Harmonica
//
//  Created by 나현흠 on 6/9/25.
//

import SwiftUI

// View의 종류에 대한 Enum
enum ViewType: Hashable {
    case STT
    case Shazam
    case Practice
    case End
}

// MARK: 화면 전환을 관리하는 객체
class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    // 화면 전환하기
    func navigate(to destination: ViewType) {
        path.append(destination)
    }
    
    // 루트로 이동하기
    func poptoRoot() {
        path.removeLast(path.count)
    }
    
    // 뒤로가기
    func pop() {
        path.removeLast()
    }
}

/*
 
 @EnvironmentObject var navigationManager: NavigationManager

 루트로 이동하기: navigationManager.poptoRoot()
 이전 화면: navigationManager.pop()
 샤잠뷰로 이동하기: navigationManager.navigate(to: .Shazam)
 STTView로 이동: navigationManager.navigate(to: .STT)
 PracticeView로 이동: navigationManager.navigate(to: .Practice)

*/
