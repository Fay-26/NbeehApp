//
//  LandingView2.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI
struct LandingView2: View {
@AppStorage("hasCompletedIntroduction")
private var hasCompletedIntroduction = false
// التحكم بالانتقال إلى الصفحة الرئيسية
@State private var goToMainView = false
var body: some View {
NavigationStack {
ZStack {
Color("mainBG")
.ignoresSafeArea()
VStack(spacing: 40) {
Spacer()
Text("دَرّب تركيزك، خطوة\nبخطوة!")
.font(
.system(
size: 36,
weight: .bold
)
)
.multilineTextAlignment(.center)
.foregroundColor(Color("textbig"))
.padding(.bottom, 40)
Image("run2")
.resizable()
.scaledToFit()
.frame(width: 220, height: 220)
.padding(.bottom, 80)
VStack(spacing: 16) {
// الانتقال إلى شرح التحدي
NavigationLink {
ChallengeExplanationView()
} label: {
Text("فهمني أكثر")
.font(
.system(
size: 28,
weight: .semibold
)
)
.foregroundColor(Color("textbig"))
.frame(width: 220, height: 70)
.padding()
.background(Color("botton"))
.cornerRadius(30)
.padding(.bottom, 20)
}
// الانتقال إلى TabScreen لعرض MainView مع شريط التبويبات
Button {
hasCompletedIntroduction = true
goToMainView = true
} label: {
Text("ابدأ التحدي")
.font(
.system(
size: 24,
weight: .medium
)
)
.foregroundColor(Color("textsmall"))
}
}
.padding(.horizontal, 32)
.padding(.bottom, 45)
}
}
.navigationDestination(isPresented: $goToMainView) {
TabScreen()
.navigationBarBackButtonHidden(true)
}
}
.environment(\.layoutDirection, .leftToRight)
}
}
#Preview {
LandingView2()
}
