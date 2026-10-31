//
//  movingPageAud.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI

struct movingPageAud: View {

    // MARK: - التنقل والحالة

    @State private var goToMainView = false
    @State private var goToVisualAttentionGame = false

    var body: some View {

        VStack(spacing: 0) {

            // MARK: - عنوان النجاح

            VStack(spacing: 8) {

                Text("رهييب!")
                    .font(
                        .system(
                            size: 80,
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
            .padding(.top, 70)

            // MARK: - الصورة والرقم

            ZStack {

                Image(.starsmove)
                    .resizable()
                    .scaledToFit()

                Text("0")
                    .font(
                        .system(
                            size: 70,
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
                .padding(.top, 30)

            // MARK: - زر مهمة الانتباه البصري

            Button {
                goToVisualAttentionGame = true
            } label: {

                Text("مهمة الإنتباه الإنتقائي")
                    .font(
                        .system(
                            size: 25,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(width: 230, height: 80)
                    .background(Color("botton"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 25)
                    )
                    .padding(.top, 30)
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
