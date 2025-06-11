//
//  SongBox.swift
//  Harmonica
//
//  Created by 나현흠 on 6/11/25.
//
import SwiftUI

struct SongBox:View {
    @State var SongName:String = ""
    @State var AlbumCover:Image?
    var action: () -> Void = {}
    var body: some View {
        Button(action: {
            action()
            playSound(sound: "ButtonSound", type: "mp3")
        }){
            ZStack(alignment: .bottomLeading){
                if let albumImage = AlbumCover {
                    albumImage
                        .resizable()
                        .scaledToFit()
                        .glur(radius: 6.0,
                              offset: 0,
                              interpolation: 0.8,
                              direction: .down
                        )
                        .cornerRadius(16)
                        .frame(width: 385, height: 269)
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2E4E4E").opacity(0.7), Color(hex: "254142")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 385, height: 269)
                Text("\(SongName)")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .padding(.leading,6)
                    .padding(.bottom, 4)
            }
        }
    }
}
