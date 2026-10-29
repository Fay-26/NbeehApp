//
//  MainView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//
import SwiftUI
private enum AudWalkDestination {
case story
case task
}
struct MainView: View {
@StateObject private var progress = UserProgress.shared
// حفظ آخر صفحة تم فتحها لمنع التكرار المتتالي
@State private var lastOpenedChallenge: AudWalkDestination? = nil
// الصفحة التي سيتم فتحها عند الضغط على زر التحدي
@State private var selectedChallenge: AudWalkDestination = .story
// التحكم في الانتقال إلى صفحة التحدي
@State private var isShowingChallenge = false
var body: some View {
ZStack(alignment: .bottom) {
Color("mainBG")
.ignoresSafeArea()
VStack(spacing: 20) {
// الشريط العلوي
HStack {
NavigationLink(
destination: AboutAppView()
) {
Image(systemName: "questionmark")
.font(.system(size: 16, weight: .bold))
.foregroundColor(Color("textsmalldark"))
.frame(width: 32, height: 32)
.background(Color("box"))
.clipShape(Circle())
}
Spacer()
Text("خلك نبيه!")
.font(.system(size: 26, weight: .bold))
.foregroundColor(Color("textbig"))
}
.padding(.horizontal, 24)
.padding(.top, 10)
// المستوى والستريك
HStack(spacing: 16) {
VStack(alignment: .trailing, spacing: 8) {
HStack {
Text("المستوى \(progress.currentLevel)")
.font(.system(size: 18, weight: .bold))
.foregroundColor(Color("textsmalldark"))
Image(systemName: "chart.bar.fill")
.foregroundColor(Color("textsmalldark"))
}
Text("مستواك الحالي")
.font(.system(size: 13, weight: .medium))
.foregroundColor(Color("textsmalldark"))
}
.frame(maxWidth: .infinity, alignment: .trailing)
.padding(16)
.background(Color("box"))
.cornerRadius(30)
VStack(alignment: .trailing, spacing: 8) {
HStack {
Text("\(progress.currentStreak) أيام")
.font(.system(size: 18, weight: .bold))
.foregroundColor(Color("textsmalldark"))
Image(systemName: "flame.fill")
.foregroundColor(Color("textsmalldark"))
}
Text("الستريك الحالي")
.font(.system(size: 13, weight: .medium))
.foregroundColor(Color("textsmalldark"))
}
.frame(maxWidth: .infinity, alignment: .trailing)
.padding(16)
.background(Color("box"))
.cornerRadius(30)
}
.padding(.horizontal, 24)
// صورة الشخصية
Image("run")
.resizable()
.scaledToFit()
.frame(height: 150)
.padding(.top, 70)
// النص التحفيزي
VStack(spacing: 6) {
Text("مستعد لتحدي اليوم ؟")
.font(.system(size: 20, weight: .bold))
.foregroundColor(Color("textbig"))
Text("خل انتباهك حاضر وخذها خطوة بخطوة.")
.font(.system(size: 15, weight: .medium))
.foregroundColor(Color("textsmall"))
}
// بطاقة تحدي اليوم
VStack(alignment: .trailing, spacing: 20) {
HStack(alignment: .top) {
VStack(alignment: .trailing, spacing: 5) {
Text(progress.dailyMission.title)
.font(.system(size: 20, weight: .bold))
.foregroundColor(Color("textsmalldark"))
Text("\(progress.dailyStepGoal.formatted()) خطوة")
.font(.system(size: 16, weight: .semibold))
.foregroundColor(Color("textsmalldark"))
Text(progress.dailyMission.description)
.font(.system(size: 13, weight: .medium))
.foregroundColor(Color("textsmalldark"))
.multilineTextAlignment(.trailing)
}
Image(
systemName: progress.dailyMission == .selectiveAttention
? "ear.badge.waveform"
: "headphones"
)
.font(.system(size: 20))
.foregroundColor(Color("textsmall"))
.padding(10)
.background(Color("taskBG"))
.cornerRadius(15)
}
// فتح تحدٍّ عشوائي دون تكرار التحدي السابق مباشرة
Button {
let nextChallenge: AudWalkDestination
if let last = lastOpenedChallenge {
switch last {
case .story:
nextChallenge = .task
case .task:
nextChallenge = .story
}
} else {
nextChallenge = Bool.random() ? .story : .task
}
selectedChallenge = nextChallenge
lastOpenedChallenge = nextChallenge
isShowingChallenge = true
} label: {
Text("ابدأ التحدي")
.font(.system(size: 20, weight: .semibold))
.foregroundColor(Color("textbig"))
.frame(maxWidth: .infinity)
.padding(.vertical, 25)
.background(Color("botton"))
.cornerRadius(30)
}
}
.padding(20)
.background(Color("box"))
.cornerRadius(50)
.padding(.horizontal, 35)
Spacer()
}
}
.navigationBarBackButtonHidden(true)
// الانتقال إلى صفحة التحدي المختارة
.navigationDestination(isPresented: $isShowingChallenge) {
Group {
switch selectedChallenge {
case .story:
AudWalkStory()
case .task:
AudWalkTask()
}
}
.navigationBarBackButtonHidden(true)
}
.onAppear {
progress.refreshDailyStepGoal()
progress.refreshDailyMission()
}
}
}
#Preview {
NavigationStack {
MainView()
}
}
