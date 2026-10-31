//
//  movingPageStory.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//
import SwiftUI

struct movingPageStory: View {

    // MARK: - التنقل والحالة

    @State private var goToMainView = false
    @State private var goToQuizView = false

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                // MARK: - عنوان النجاح

                VStack(spacing: 8) {

                    Text("رهييب!")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundStyle(Color("textbig"))

                    Text("خلصت خطواتك")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(Color("textsmall"))
                }
                .padding(.top, 70)

                // MARK: - النجوم والرقم

                ZStack {

                    Image(.starsmove)
                        .resizable()
                        .scaledToFit()

                    Text("0")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundStyle(Color("textbig"))
                }
                .frame(
                    width: min(geometry.size.width * 0.72, 280),
                    height: min(geometry.size.width * 0.72, 280)
                )
                .frame(maxWidth: .infinity)
                .padding(.top, 24)

                // MARK: - النص أسفل الصورة

                Text("الحين جاء وقت الإجابة على أسئلة القصة")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(Color("textsmall"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 30)

                Spacer(minLength: 20)

                // MARK: - زر جاهز

                Button {
                    goToQuizView = true
                } label: {

                    Text("جاهز")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 245, height: 96)
                        .background(
                            Color("botton"),
                            in: RoundedRectangle(cornerRadius: 32)
                        )
                }
                .buttonStyle(.plain)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Color("mainBG"))


            // MARK: - الانتقال إلى MainView

            .navigationDestination(isPresented: $goToMainView) {

                MainView()
                    .navigationBarBackButtonHidden(true)
            }

            // MARK: - الانتقال إلى QuizView

            .navigationDestination(isPresented: $goToQuizView) {

                QuizView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        movingPageStory()
    }
}
