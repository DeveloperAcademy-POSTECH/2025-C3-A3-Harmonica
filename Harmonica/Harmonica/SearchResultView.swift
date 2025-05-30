import SwiftUI

struct SearchResultView: View {
    var body: some View {
        VStack{
            Text("찾으시던게 이 노래인가요?")
                .font(
                    Font.custom("SF Pro", size: 64)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
            Spacer()
            ZStack{
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 896, height: 366)
                    .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                    .cornerRadius(20)
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 848, height: 318)
                    .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                    .cornerRadius(30)
                HStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 270, height: 270)
                        .background(Color(red: 0.7, green: 0.7, blue: 0.7))
                        .cornerRadius(100)
                    Text("진진자라\n-남진")
                        .font(
                            Font.custom("SF Pro", size: 64)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                }
                ZStack{
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 910, height: 205)
                        .background(Color(red: 0.22, green: 0.22, blue: 0.22))
                        .cornerRadius(20)
                    HStack{
                        ZStack{
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 419, height: 157)
                                .background(Color(red: 0.75, green: 0.75, blue: 0.75))
                                .cornerRadius(30)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 362, height: 121)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(100)
                                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .inset(by: 1.5)
                                        .stroke(.white.opacity(0.7), lineWidth: 3)
                                )
                            Text("다시 노래 찾기")
                                .font(
                                    Font.custom("SF Pro", size: 48)
                                        .weight(.medium)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                        }
                        ZStack{
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 419, height: 157)
                                .background(Color(red: 0.83, green: 0.81, blue: 0.78))
                                .cornerRadius(30)
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 362, height: 121)
                                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                                .cornerRadius(100)
                                .shadow(color: .black.opacity(0.25), radius: 25, x: 0, y: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 100)
                                        .inset(by: 1.5)
                                        .stroke(.white.opacity(0.7), lineWidth: 3)
                                )
                            Text("연습하러가기")
                                .font(
                                    Font.custom("SF Pro", size: 48)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                        }
                    }
                }
            }
        }
    }
}
