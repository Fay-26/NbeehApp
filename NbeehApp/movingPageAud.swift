//
//  movingPageAud.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI

struct movingPageAud: View {

    // MARK: - التنقل والحالة

    @State private var showExitConfirmation = false
    @State private var goToMainView = false
    @State private var goToVisualAttentionGame = false

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - زر الخروج

            HStack {

                Button {
                    showExitConfirmation = true
                } label: {

                    Image(systemName: "xmark")
                        .font(
                            .system(
                                size: 30,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(Color("taskBG"))
                        .frame(width: 48, height: 48)
                        .background(
                            Color("box"),
                            in: Circle()
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("الخروج من التحدي")

                Spacer()
            }
            .padding(.horizontal, 8)

            // MARK: - عنوان النجاح

            VStack(spacing: 8) {

                Text("رهييب!")
                    .font(
                        .system(
                            size: 72,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(Color("textbig"))

                Text("خلصت خطواتك")
                    .font(
                        .system(
                            size: 28,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(Color("textsmall"))
            }
            .padding(.top, 40)

            // MARK: - الصورة والرقم

            ZStack {

                Image(.starsmove)
                    .resizable()
                    .scaledToFit()

                Text("0")
                    .font(
                        .system(
                            size: 64,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(Color("textbig"))
            }
            .frame(width: 280, height: 280)
            .frame(maxWidth: .infinity)
            .padding(.top, 24)

            // MARK: - النص التحفيزي

            Text("وعشان تدرب تركيزك أكثر،\nكمل آخر جزء من التحدي!")
                .font(
                    .system(
                        size: 24,
                        weight: .regular
                    )
                )
                .foregroundStyle(Color("textsmall"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 8)

            // MARK: - زر مهمة الانتباه البصري

            Button {
                goToVisualAttentionGame = true
            } label: {

                Text("مهمة الانتباه البصري")
                    .font(
                        .system(
                            size: 20,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(width: 220, height: 70)
                    .background(Color("botton"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )
                    .padding(.top, 20)
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Color("mainBG"))

        // MARK: - تأكيد الخروج

        .alert(
            "هل أنت متأكد من الخروج؟",
            isPresented: $showExitConfirmation
        ) {

            Button("استمرار", role: .cancel) {
                // البقاء في الصفحة الحالية
            }

            Button("خروج", role: .destructive) {
                goToMainView = true
            }

        } message: {

            Text("الخروج يؤدي إلى إعادة المرحلة من جديد.")
        }

        // MARK: - الانتقال إلى MainView

        .navigationDestination(isPresented: $goToMainView) {

            MainView()
                .navigationBarBackButtonHidden(true)
        }

        // MARK: - الانتقال إلى تحدي الانتباه البصري

        .navigationDestination(
            isPresented: $goToVisualAttentionGame
        ) {

            VisualAttentionGame()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        movingPageAud()
    }
}
