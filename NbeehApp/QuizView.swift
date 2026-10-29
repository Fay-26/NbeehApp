//
//  QuizView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//


import SwiftUI

// MARK: - نموذج السؤال

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: Int
}

// MARK: - نموذج القصة

struct QuizStory {
    let questions: [QuizQuestion]
}

// MARK: - نتائج الاختبار

struct ChallengeResult {
    let correctAnswers: Int
    let wrongAnswers: Int

    var totalQuestions: Int {
        correctAnswers + wrongAnswers
    }

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }

        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
}

// MARK: - شاشة الاختبار

struct QuizView: View {

    // MARK: - الألوان

    private let backgroundColor = Color("taskBG")
    private let questionColor = Color("box")
    private let buttonColor = Color("botton")
    private let questionTextColor = Color("textsmalldark")
    private let answerTextColor = Color("textbig")
    private let borderColor = Color("box")

    // MARK: - التنقل

    @State private var showExitAlert = false
    @State private var goToVisualTask = false
    @State private var goToMainView = false
    @State private var hasStartedNavigation = false

    // MARK: - أسئلة قصة سارة

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            question: "سارة إيش تحب وتفضّل؟",
            options: ["المودرن", "الانتيك", "البوهيمي"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "ليش نقلت سارة شقة جديدة؟",
            options: [
                "أقرب لدوامها",
                "سعرها مناسب",
                "انتهى عقدها"
            ],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "إيش كان لون جدار الغرفة اللي بالانعكاس؟",
            options: ["أحمر", "أحمر مخملي", "وردي"],
            correctAnswer: 1
        ),
        QuizQuestion(
            question: "كم كان التاريخ بانعكاس المرايا؟",
            options: [
                "1996/10/27",
                "2000/11/13",
                "1998/2/16"
            ],
            correctAnswer: 0
        ),
        QuizQuestion(
            question: "إيش قالت البنت لسارة؟",
            options: ["أنقذيني", "الدور الجاي عليك", "انحاشي"],
            correctAnswer: 2
        )
    ]

    // MARK: - حالة الاختبار

    @State private var currentQuestionIndex = 0
    @State private var correctAnswers = 0
    @State private var wrongAnswers = 0
    @State private var selectedAnswer: Int? = nil
    @State private var hasAnswered = false

    // MARK: - السؤال الحالي

    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }

    private var challengeResult: ChallengeResult {
        ChallengeResult(
            correctAnswers: correctAnswers,
            wrongAnswers: wrongAnswers
        )
    }

    // MARK: - الواجهة

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView
                progressView
                questionView

                Spacer(minLength: 35)

                answersView

                Spacer(minLength: 35)
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 20)
            .environment(\.layoutDirection, .rightToLeft)
        }
        .navigationBarBackButtonHidden(true)

        // الانتقال إلى تحدي الانتباه البصري
        .navigationDestination(isPresented: $goToVisualTask) {
            VisualAttentionGame(
                auditoryCorrectAnswers: challengeResult.correctAnswers,
                auditoryWrongAnswers: challengeResult.wrongAnswers
            )
            .navigationBarBackButtonHidden(true)
        }

        // الانتقال إلى MainView عند تأكيد الخروج
        .navigationDestination(isPresented: $goToMainView) {
            MainView()
                .navigationBarBackButtonHidden(true)
        }

        // تنبيه تأكيد الخروج
        .alert(
            "هل أنت متأكد من الخروج؟",
            isPresented: $showExitAlert
        ) {
            Button("استمرار", role: .cancel) {
                // إغلاق التنبيه ومتابعة الاختبار
            }

            Button("خروج", role: .destructive) {
                hasStartedNavigation = true
                goToMainView = true
            }
        } message: {
            Text("الخروج يؤدي إلى إعادة المرحلة من جديد.")
        }
    }

    // MARK: - رأس الصفحة

    private var headerView: some View {
        HStack {
            Button {
                showExitAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.black)
                    .frame(width: 48, height: 48)
                    .background(
                        Color(
                            red: 194.0 / 255.0,
                            green: 169.0 / 255.0,
                            blue: 201.0 / 255.0
                        ),
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("الخروج من الاختبار")

            Spacer()

            Text("تحدي الانتباه السمعي")
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(Color("mainBG"))
                .padding(.horizontal, 12)
                .padding(.vertical, 18)
                .background(
                    Color("box"),
                    in: RoundedRectangle(cornerRadius: 20)
                )

            Spacer()

            Image(systemName: "ear.badge.waveform")
                .font(.system(size: 35, weight: .semibold))
                .foregroundStyle(Color("box"))
                .accessibilityHidden(true)
        }
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - التقدم

    private var progressView: some View {
        HStack {
            Text(
                "السؤال \(currentQuestionIndex + 1) من \(questions.count)"
            )
            .font(.system(size: 13))
            .foregroundStyle(questionTextColor.opacity(0.8))

            Spacer()

            Text("✓ \(correctAnswers)   ✕ \(wrongAnswers)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(questionTextColor)
                .accessibilityLabel(
                    "الإجابات الصحيحة \(correctAnswers)، والإجابات الخاطئة \(wrongAnswers)"
                )
        }
        .padding(.top, 28)
    }

    // MARK: - السؤال

    private var questionView: some View {
        VStack(spacing: 10) {
            Text(currentQuestion.question)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(questionTextColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 135)
                .padding(.horizontal, 16)
                .background(questionColor)
                .clipShape(RoundedRectangle(cornerRadius: 32))

            Text(
                "دقة الإجابات: \(Int(challengeResult.accuracy.rounded()))٪"
            )
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(questionTextColor.opacity(0.8))
        }
        .padding(.top, 34)
    }

 
    // MARK: - الخيارات

    private var answersView: some View {
        VStack(spacing: 24) {
            ForEach(currentQuestion.options.indices, id: \.self) { index in
                Button {
                    selectAnswer(index)
                } label: {
                    Text(currentQuestion.options[index])
                        .font(.system(size: 16))
                        .foregroundStyle(answerTextColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            selectedAnswer == index
                                ? buttonColor
                                : Color.clear
                        )
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .stroke(borderColor, lineWidth: 0.8)
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .contentShape(Capsule())
                .disabled(hasAnswered || hasStartedNavigation)
            }
        }
        .padding(.horizontal, 2)
    }


    // MARK: - اختيار الإجابة

    private func selectAnswer(_ index: Int) {
        guard
            !hasAnswered,
            !hasStartedNavigation,
            questions.indices.contains(currentQuestionIndex),
            currentQuestion.options.indices.contains(index)
        else {
            return
        }

        hasAnswered = true
        selectedAnswer = index

        if index == currentQuestion.correctAnswer {
            correctAnswers += 1
        } else {
            wrongAnswers += 1
        }

        let answeredLastQuestion =
            currentQuestionIndex == questions.count - 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard !hasStartedNavigation else { return }

            if answeredLastQuestion {
                hasStartedNavigation = true
                goToVisualTask = true
            } else {
                currentQuestionIndex += 1
                selectedAnswer = nil
                hasAnswered = false
            }
        }
    }
}

// MARK: - المعاينة

#Preview {
    NavigationStack {
        QuizView()
    }
}
