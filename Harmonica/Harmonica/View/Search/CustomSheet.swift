import Foundation
import SwiftUI

struct CustomSheet<Item: Identifiable & Equatable, SheetContent: View>: ViewModifier {
  @Binding var item: Item?
  var onDismiss: (() -> Void)? = nil
  
  let sheetContent: (Item) -> SheetContent
  
  @State private var previousItem: Item?
  
  func body(content: Content) -> some View {
    ZStack {
      content
      
      if let item = item {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .transition(.opacity)
        
        sheetContent(item)
          .background(
            RoundedRectangle(cornerRadius: 40).fill(Color.white)
          )
          .frame(maxWidth: .infinity)
          .transition(.opacity)
          .zIndex(1)
      }
    }
    
    .onChange(of: item) { _, newValue in
      withAnimation {
        if previousItem != nil && newValue == nil {
          onDismiss?()
        }
        previousItem = newValue
      }
    }
  }
}

struct CustomSheet2<SheetContent: View>: ViewModifier {
  @Binding var isPresented: Bool
  var onDismiss: (() -> Void)? = nil
  let sheetContent: () -> SheetContent
  
  @State private var previousIsPresented = false
  
  func body(content: Content) -> some View {
    ZStack {
      content
      if isPresented {
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .transition(.opacity)
        
        sheetContent()
          .background(
            RoundedRectangle(cornerRadius: 40).fill(Color.white)
          )
          .frame(maxWidth: .infinity)
          .transition(.opacity)
          .zIndex(1)
      }
    }
    .onChange(of: isPresented) {  _, newValue in
      withAnimation {
        if previousIsPresented == true && newValue == false {
          onDismiss?()
        }
        previousIsPresented = newValue
      }
    }
    
  }
}

extension View {
  // Bool 트리거용 시트
  func customSheet<Content: View>(
    isPresented: Binding<Bool>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    self.modifier(CustomSheet2(isPresented: isPresented, onDismiss: onDismiss, sheetContent: content))
  }
  
  // Identifiable Item 트리거용 시트
  func customSheet<Item: Identifiable & Equatable, Content: View>(
    item: Binding<Item?>,
    onDismiss: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    self.modifier(CustomSheet(item: item, onDismiss: onDismiss, sheetContent: content))
  }
}

#Preview(body: {
  STTView()
})
