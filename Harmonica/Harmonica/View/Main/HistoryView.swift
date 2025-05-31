import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 700, height: 924)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.05, green: 0.05, blue: 0.05), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.31, green: 0.31, blue: 0.31), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.14, y: 0.17),
                        endPoint: UnitPoint(x: 0.9, y: 0.96)
                    )
                )
                .cornerRadius(20)
            ScrollView{
                
            }
        }
    }
}
