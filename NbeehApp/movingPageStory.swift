//
//  movingPageStory.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//
import SwiftUI

struct movingPageStory: View {

    // MARK: - التنقل والحالة

    @State private var showExitConfirmation = false
    @State private var goToMainView = false
    @State private var goToQuizView = false

    var body: some View {

        GeometryReader { geometry in

            VStack(spacing: 0) {

                // MARK: - زر الخروج

                HStack {

                    Button {
                        showExitConfirmation = true
                    } label: {

                        Image(systemName: "xmark")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundStyle(Color("taskBG"))
                            .frame(width: 48, height: 48)
                            .background(Color("box"), in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("الخروج من التحدي")

                    Spacer()
                }
                .padding(.horizontal, 8)

                // MARK: - عنوان النجاح

                VStack(spacing: 8) {

                    Text("رهييب!")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(Color("textbig"))

                    Text("خلصت خطواتك")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundStyle(Color("textsmall"))
                }
                .padding(.top, 12)

                // MARK: - النجوم والرقم

                ZStack {

                    Image(.starsmove)
                        .resizable()
                        .scaledToFit()

                    Text("0")
                        .font(.system(size: 64, weight: .bold))
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
                    .padding(.horizontal, 8)
                    .padding(.top, 16)

                Spacer(minLength: 20)

                // MARK: - زر جاهز

                Button {
                    goToQuizView = true
                } label: {

                    Text("جاهز")
                        .font(.system(size: 30, weight: .semibold))
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

            // MARK: - تأكيد الخروج

            .alert(
                "هل أنت متأكد من الخروج؟",
                isPresented: $showExitConfirmation
            ) {

                Button("استمرار", role: .cancel) {
                    // إغلاق التنبيه والبقاء في الصفحة
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
