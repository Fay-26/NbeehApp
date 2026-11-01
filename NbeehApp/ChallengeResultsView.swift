//
//  ChallengeResultsView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//



import SwiftUI

struct ChallengeResultsView: View {

    var auditoryCorrectAnswers: Int = 0
    var visualCorrectAnswers: Int = 0
    var visualTotalErrors: Int = 0
    var visualAverageReactionTime: Double = 0

    var onFinished: () -> Void = {}

    // Performance results store
    @ObservedObject private var store = PerformanceStore.shared

    @State private var opacity: Double = 0
    @State private var navigateToTabScreen = false

    // MARK: - Scores

    private var auditoryScore: Int {
        min(5, max(0, auditoryCorrectAnswers))
    }

    private var visualScore: Int {
        min(5, max(0, visualCorrectAnswers))
    }

    private var totalCorrect: Int {
        auditoryScore + visualScore
    }

    private var totalQuestions: Int {
        10
    }

    private var accuracy: Int {
        Int(
            (
                Double(totalCorrect)
                / Double(totalQuestions)
                * 100
            )
            .rounded()
        )
    }

    // MARK: - Save Today's Performance

    private func saveTodayPerformance() {

        let session = DailyPerformance(
            date: Date(),
            steps: 0,
            auditoryCorrect: auditoryScore,
            auditoryTotal: 5,
            visualCorrect: visualScore,
            visualTotal: 5,
            isCompleted: true
        )

        _ = store.save(session)
    }

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                Color("mainBG")
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    ZStack {

                        Image("starsmove2")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: geometry.size.width * 0.82,
                                height: geometry.size.height * 0.38
                            )

                        VStack(spacing: 12) {

                            Text("كفوو!")
                                .font(
                                    .system(
                                        size: 76,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    Color("textbig")
                                )

                            Text("خلصت تحدي اليوم")
                                .font(
                                    .system(size: 25)
                                )
                                .foregroundStyle(
                                    Color("textbig")
                                )
                        }
                        .multilineTextAlignment(.center)
                    }
                    .frame(
                        height: geometry.size.height * 0.40
                    )
                    .padding(.top, 3)

                    Spacer(minLength: 8)

                    VStack(
                        alignment: .trailing,
                        spacing: 0
                    ) {

                        ScrollView {

                            Text("نتائج التحدي:")
                                .font(
                                    .system(
                                        size: 33,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    Color("mainBG")
                                )
                                .padding(.bottom, 24)

                            // MARK: Auditory Attention

                            Text("الانتباه السمعي:")
                                .font(
                                    .system(size: 23)
                                )
                                .foregroundStyle(
                                    Color("mainBG")
                                )

                            HStack(spacing: 0) {

                                ForEach(
                                    0..<5,
                                    id: \.self
                                ) { index in

                                    resultSymbol(
                                        index < auditoryScore
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            .padding(.bottom, 24)

                            // MARK: Visual Attention

                            Text("الانتباه البصري:")
                                .font(
                                    .system(size: 23)
                                )
                                .foregroundStyle(
                                    Color("mainBG")
                                )

                            HStack(spacing: 0) {

                                ForEach(
                                    0..<5,
                                    id: \.self
                                ) { index in

                                    resultSymbol(
                                        index < visualScore
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 18)
                            .padding(.bottom, 24)

                            Divider()
                                .overlay(
                                    Color("mainBG")
                                        .opacity(0.25)
                                )

                            // MARK: Total Accuracy

                            HStack {

                                Text("\(accuracy)%")
                                    .font(
                                        .system(
                                            size: 25,
                                            weight: .bold
                                        )
                                    )

                                Spacer()

                                Text("الدقة الإجمالية")
                                    .font(
                                        .system(size: 20)
                                    )
                            }
                            .foregroundStyle(
                                Color("mainBG")
                            )
                            .padding(.top, 18)

                            // MARK: Visual Errors

                            HStack {

                                Text(
                                    "\(max(0, visualTotalErrors))"
                                )
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .bold
                                    )
                                )

                                Spacer()

                                Text("الأخطاء البصرية")
                                    .font(
                                        .system(size: 18)
                                    )
                            }
                            .foregroundStyle(
                                Color("mainBG")
                            )
                            .padding(.top, 12)

                            // MARK: Reaction Time

                            if visualAverageReactionTime > 0 {

                                HStack {

                                    Text(
                                        String(
                                            format: "%.2f ثانية",
                                            visualAverageReactionTime
                                        )
                                    )
                                    .font(
                                        .system(
                                            size: 18,
                                            weight: .bold
                                        )
                                    )

                                    Spacer()

                                    Text("متوسط سرعة الاستجابة")
                                        .font(
                                            .system(size: 18)
                                        )
                                }
                                .foregroundStyle(
                                    Color("mainBG")
                                )
                                .padding(.top, 12)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 22)
                    .padding(.bottom, 24)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: geometry.size.height * 0.54,
                        alignment: .topTrailing
                    )
                    .background(
                        Color("box")
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 35
                        )
                    )
                    .padding(.horizontal, 22)

                    Spacer(minLength: 12)
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .opacity(opacity)
            }
        }
        .preferredColorScheme(.dark)

        // Navigate to TabScreen automatically
        .navigationDestination(
            isPresented: $navigateToTabScreen
        ) {
            TabScreen()
                .navigationBarBackButtonHidden(true)
        }

        .task {

            // Save today's challenge results
            saveTodayPerformance()

            withAnimation(
                .easeIn(duration: 0.10)
            ) {
                opacity = 1
            }

            do {

                try await Task.sleep(
                    nanoseconds: 800_000_000
                )

                try Task.checkCancellation()

                try await Task.sleep(
                    nanoseconds: 4_500_000_000
                )

                try Task.checkCancellation()

                withAnimation(
                    .easeOut(duration: 0.8)
                ) {
                    opacity = 0
                }

                try await Task.sleep(
                    nanoseconds: 800_000_000
                )

                try Task.checkCancellation()

                // Go to TabScreen after results disappear
                navigateToTabScreen = true

            } catch {

                // Stop waiting if the user leaves the screen.
            }
        }
    }

    // MARK: - Result Symbol

    private func resultSymbol(
        _ success: Bool
    ) -> some View {

        Image(
            systemName: success
                ? "checkmark.circle"
                : "minus.circle"
        )
        .font(
            .system(
                size: 33,
                weight: .medium
            )
        )
        .foregroundStyle(
            Color("mainBG")
        )
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {

        ChallengeResultsView(
            auditoryCorrectAnswers: 3,
            visualCorrectAnswers: 4,
            visualTotalErrors: 1,
            visualAverageReactionTime: 1.25
        )
    }
}
