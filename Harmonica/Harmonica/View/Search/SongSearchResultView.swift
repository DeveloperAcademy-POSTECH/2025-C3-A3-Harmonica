import SwiftUI

struct SongSearchResultView {
    let item: Item?
    let closeAction: () -> Void // 닫기
    let selectAction: (String) -> Void // 노래를 선택하고 아이디를 넘겨줌
    let playAction: (URL) -> Void // 미리듣기 재생 액션
    let resetActoin: () -> Void // 메인 뷰로 이동
    let musicManager = MusicManager()
    
    @EnvironmentObject var navigationManager: NavigationManager
}

extension SongSearchResultView { }

extension SongSearchResultView: View {
    var body: some View {
        VStack {
            
            if let item = item {
                VStack {
                    VStack(spacing: 56) {
                        Text("찾으시던 노래가 맞으신가요?")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(Color(hex: "254142"))
                        
                        if let artworkURL = item.artworkURL {
                            HStack(spacing: 25) {
                                AsyncImage(url: artworkURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 270, height: 270)
                                .clipShape(.rect(cornerRadius: 30))
                                
                                VStack(alignment: .leading) {
                                    Text(item.artist)
                                    Text(item.title)
                                }
                                .font(.system(size: 64, weight: .bold))
                                .foregroundStyle(Color(uiColor: UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1)))
                                .lineLimit(1)
                            }
                            .frame(height: 277)
                            .frame(maxWidth: 882)
                        }
                        HStack(spacing: 50) {
                            Button(action: {
                                playSound(sound: "ButtonSound", type: "mp3")
                                closeAction()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(hex: "505050"))
                                    Text("다시 노래 찾기")
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
                                selectAction(item.id)
                                musicManager.stopPreview()
                                
                            }) {
                                HStack {
                                    Image(systemName: "music.quarternote.3")
                                        .font(.system(size: 48))
                                        .foregroundColor(Color(hex: "005F61"))
                                    Text("노래연습 시작")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(Color(hex: "005F61"))
                                }
                                .frame(width: 416, height: 100)
                                .background(Color(hex: "C8E9EA"))
                                .cornerRadius(16)
                            }
                        }
                    }
                    .frame(height: 546)
                    .padding(.vertical)
                }

                .frame(width: 1022, height: 687)
                .onAppear {
                    if let url = item.previewURL {
                        playAction(url)
                    }
                }
            } else {
                VStack(spacing: 56) {
                    VStack(alignment: .center, spacing: .zero) {
                        Text("요청하신 노래를 찾지 못했습니다.")
                        
                        Text("다시 검색해주세요.")
                    }
                    .font(.system(size: 48, weight: .semibold))
                    //----------------------------------------
                    .foregroundStyle(Color(uiColor: UIColor(red: 0.15, green: 0.26, blue: 0.26, alpha: 1)))
                    
                    HStack(spacing: 50) {
                        Button(action: {
                            resetActoin()
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
                            closeAction()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(Color(hex: "005F61"))
                                Text("다시 노래 찾기")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(Color(hex: "005F61"))
                            }
                            .frame(width: 416, height: 100)
                            .background(Color(hex: "C8E9EA"))
                            .cornerRadius(16)
                        }
                    }
                }
                .frame(width: 1022, height: 426)
            }
        }
    }
}
