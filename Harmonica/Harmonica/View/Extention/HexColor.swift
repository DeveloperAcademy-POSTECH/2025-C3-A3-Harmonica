//
//  HexColor.swift
//  Harmonica
//
//  Created by 나현흠 on 6/8/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // "#" 기호 제거
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// .white 같은 형식으로 넣어야할 때 Color(hex: "(헥스 코드 값") 을 넣어서 사용 가능
// ex) Color(hex: "2E4E4E").opacity(0.7), .foregroundColor(Color(hex: "505050"))

