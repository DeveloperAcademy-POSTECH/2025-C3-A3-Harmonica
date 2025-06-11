//
//  HistoryResultView.swift
//  Harmonica
//
//  Created by 나현흠 on 6/11/25.
//
import SwiftUI

struct HistoryResultView: View {
    @Binding var isPresented: Bool
    @State private var selectedSongIndex: Int? = nil
    @State private var isPlaying: Bool = false
    @State private var isLoading: Bool = false
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ZStack{
            VStack {
                VStack(spacing: 56) {
                    Text("이 노래를 연습할까요?")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(Color(hex: "254142"))
                    HStack(spacing: 25) {
                        Image("내 여자 내 남자 커버")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 270, height: 270)
                            .clipShape(.rect(cornerRadius: 30))
                            .shadow(radius: 4, y: 4)
                        
                        VStack(alignment: .leading) {
                            Text("배금성")
                            Text("내 여자 내 남자")
                        }
                        .font(.system(size: 64, weight: .bold))
                        .foregroundColor(Color(hex: "4A4A4A"))
                    }
                }
                HStack(spacing: 50) {
                    Button(action: {
                        playSound(sound: "ButtonSound", type: "mp3")
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "power.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "505050"))
                            Text("처음으로 가기")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "505050"))
                        }
                        .frame(width: 416, height: 100)
                        .background(Color(hex: "DDDDDD"))
                        .cornerRadius(16)
                    }
                    .frame(width: 416, height: 100.0)
                    
                    Button(action: {
                        playSound(sound: "ButtonSound", type: "mp3")
                        isPresented = false
                        navigationManager.navigate(to: .Loading)
                    }) {
                        HStack {
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: 48))
                                .foregroundColor(Color(hex: "005F61"))
                            Text("노래 연습 시작")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "005F61"))
                        }
                        
                        .frame(width: 416, height: 100)
                        .background(Color(hex: "C8E9EA"))
                        .cornerRadius(16)
                    }
                    
                }
            }
            .padding(.vertical, 10)
            .navigationBarHidden(true)
        }
        
    }
}
