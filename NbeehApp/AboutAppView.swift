//
//  AboutAppView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI

struct AboutAppView: View {

    @State private var goToMainView = false

    var body: some View {

        ZStack {

            // خلفية الشاشة
            Color("mainBG")
                .ignoresSafeArea()

            VStack(spacing: 30) {

                Spacer()

                // بطاقة معلومات التطبيق
                VStack(
                    alignment: .trailing,
                    spacing: 20
                ) {

                    // عن التطبيق
                    VStack(
                        alignment: .trailing,
                        spacing: 10
                    ) {

                        Text("عن التطبيق")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("textsmalldark"))

                        Text("""
                            يهدف نبيه إلى مساعدة المستخدم على تحسين انتباهه والحد من التشتت الناتج عن كثرة المشتتات الرقمية.

                            ويركّز التطبيق على تنمية نوعين من الانتباه: الانتباه الانتقائي، من خلال التركيز على عناصر محددة وتجاهل المشتتات، والانتباه المستمر، من خلال المحافظة على التركيز لفترة زمنية.
                            """)
                        
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("textsmalldark"))
                        .multilineTextAlignment(.trailing)
                        .padding(.top, 20)
                    }

                    Divider()
                        .background(
                            Color("textsmalldark").opacity(0.3)
                        )

                    // طريقة استخدام التطبيق
                    VStack(
                        alignment: .trailing,
                        spacing: 14
                    ) {

                        Text("كيف تستخدم التطبيق؟")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color("textsmalldark"))

                        // الخطوة الأولى
                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {

                            Text("امشي عدد الخطوات المطلوب في كل مرحلة.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("textsmalldark"))
                                .multilineTextAlignment(.trailing)
                                .padding(.top, 20)

                            Image(systemName: "figure.walk")
                                .font(.system(size: 20))
                                .foregroundColor(Color("textsmalldark"))
                                .frame(width: 20)
                                .padding(.top, 15)
                        }

                        // الخطوة الثانية
                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {

                            Text("اسمع للأصوات المستهدفة لتدريب إنتباهك المستمر واستجب لها أثناء المشي.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("textsmalldark"))
                                .multilineTextAlignment(.trailing)

                            Image(systemName: "ear.and.waveform")
                                .font(.system(size: 20))
                                .foregroundColor(Color("textsmalldark"))
                                .frame(width: 20)
                        }

                        // الخطوة الثالثة
                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {

                            Text("أكمل نشاط الإنتباه الإنتقائي بعد إنهاء خطواتك.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("textsmalldark"))
                                .multilineTextAlignment(.trailing)

                            Image(systemName: "eye")
                                .font(.system(size: 20))
                                .foregroundColor(Color("textsmalldark"))
                                .frame(width: 20)
                                .padding(.bottom, 30)
                        }
                    }
                }
                .padding(24)
                .background(Color("box"))
                .cornerRadius(40)
                .padding(.horizontal, 40)

                Spacer()

                // زر فهمت: الانتقال إلى MainView
                Button {
                    goToMainView = true
                } label: {

                    Text("فهمت")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color("textbig"))
                        .frame(width: 220, height: 70)
                        .padding()
                        .background(Color("botton"))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 30)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)

        // وجهة الانتقال
        .navigationDestination(isPresented: $goToMainView) {
            MainView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        AboutAppView()
    }
}
