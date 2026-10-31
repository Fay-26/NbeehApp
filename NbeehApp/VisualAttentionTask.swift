//
//  ContentView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI
struct VisualAttentionTask: View {
var body: some View {
ZStack {
Color("mainBG")
.ignoresSafeArea()
VStack(spacing: 5) {
Text("فنااان!")
.font(.system(size: 80))
.foregroundStyle(Color("textbig"))
.padding(.top, 60)
Text("خلصت من مهمة الإنتباه المستمر")
.font(.system(size: 24))
.multilineTextAlignment(.center)
.foregroundStyle(Color("textsmall").opacity(0.8))
.padding(.top, 28)
Spacer()
Image("smart")
.resizable()
.scaledToFit()
.frame(width: 320, height: 270)
Text("وعشان تدرب تركيزك أكثر كمل اخر جزء من التحدي")
.font(.system(size: 23))
.multilineTextAlignment(.center)
.foregroundStyle(Color("textsmall").opacity(0.8))
.padding(.top, 55)
Spacer()
NavigationLink {
VisualAttentionGame()
.navigationBarBackButtonHidden(true)
} label: {
Text("مهمة الإنتباه الإنتقائي")
.font(.system(size: 25))
.foregroundStyle(Color("textbig"))
.frame(width: 230, height: 80)
.background(Color("botton"))
.clipShape(
RoundedRectangle(cornerRadius: 25)
)
.contentShape(
RoundedRectangle(cornerRadius: 30)
)
}
.buttonStyle(.plain)
.padding(.bottom, 30)
}
}
.preferredColorScheme(.dark)
.navigationBarBackButtonHidden(true)
}
}
#Preview {
NavigationStack {
VisualAttentionTask()
}
}
