//
//  ChallengeExplanationView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//


import SwiftUI

struct ChallengeExplanationView: View {

    @AppStorage("hasCompletedIntroduction")
    private var hasCompletedIntroduction = false

    var body: some View {

        ZStack {

            Color("mainBG")
                .ignoresSafeArea()

            VStack(spacing: 24) {

                Spacer()

                Text("امشِ, اسمع, ركّز!")
                    .font(.system(size: 50))
                    .foregroundColor(Color("textbig"))
                    .padding(.bottom, 30)

                VStack(
                    alignment: .trailing,
                    spacing: 70
                ) {

                    // الخطوة الأولى: المشي
                    HStack(
                        alignment: .center,
                        spacing: 20
                    ) {

                        Text("امشِ عدد الخطوات المطلوب في كل مرحلة.")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(Color("textsmalldark"))
                            .multilineTextAlignment(.trailing)

                        Image(systemName: "figure.walk")
                            .font(.system(size: 25))
                            .foregroundColor(Color("textsmalldark"))
                            .frame(width: 22)
                            .padding(.top, 10)
                    }

                    // الخطوة الثانية: الانتباه السمعي
                    HStack(
                        alignment: .center,
                        spacing: 20
                    ) {

                        Text("اسمع للأصوات المستهدفة لتدريب إنتباهك المستمر واستجب لها أثناء المشي.")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(Color("textsmalldark"))
                            .multilineTextAlignment(.trailing)

                        Image(systemName: "ear.and.waveform")
                            .font(.system(size: 25))
                            .foregroundColor(Color("textsmalldark"))
                            .frame(width: 24)
                    }

                    // الخطوة الثالثة: الانتباه البصري
                    HStack(
                        alignment: .center,
                        spacing: 20
                    ) {

                        Text("أكمل نشاط الإنتباه الإنتقائي بعد إنهاء خطواتك.")
                            .font(
                                .system(
                                    size: 20,
                                    weight: .medium
                                )
                            )
                            .foregroundColor(Color("textsmalldark"))
                            .multilineTextAlignment(.trailing)

                        Image(systemName: "eye")
                            .font(.system(size: 25))
                            .foregroundColor(Color("textsmalldark"))
                            .frame(width: 24)
                    }
                }
                .padding(24)
                .background(Color("box"))
                .cornerRadius(50)
                .padding(.horizontal, 30)
                
                Spacer()

                Text("أكمل تحديك اليومي ودَرّب انتباهك")
                    .font(
                        .system(
                            size: 20,
                            weight: .regular
                        )
                    )
                    .foregroundColor(Color("textsmall"))

                // الانتقال إلى MainView
                NavigationLink {
                    MainView()
                } label: {

                    Text("يلا نبدأ التحدي")
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
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        hasCompletedIntroduction = true
                    }
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 45)
            }
        }
        .navigationBarBackButtonHidden(true)
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    NavigationStack {
        ChallengeExplanationView()
    }
}
