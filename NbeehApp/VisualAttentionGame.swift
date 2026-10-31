//
//  VisualAttentionGame.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI

// MARK: - نماذج اللعبة

private enum GameShape: CaseIterable {
    case circle
    case triangle
    case square
}

private struct GameTile: Identifiable {
    let id = UUID()
    let shape: GameShape
    let colorIndex: Int
}

// MARK: - تحدي الانتباه البصري

struct VisualAttentionGame: View {

    // MARK: - نتائج الاختبار السمعي

    var auditoryCorrectAnswers: Int = 0
    var auditoryWrongAnswers: Int = 0

    // MARK: - التنقل والحالة

    @Environment(\.dismiss) private var dismiss

    @StateObject private var progress = UserProgress.shared
    @StateObject private var performance = PerformanceStore.shared

    @AppStorage("visualAttentionDifficulty")
    private var difficultyLevel = 0

    @State private var showExitAlert = false
    @State private var goToMainView = false

    @State private var roundNumber = 1
    @State private var boardTiles: [GameTile] = []
    @State private var targetShape: GameShape = .triangle

    @State private var isFinished = false
    @State private var isProcessingSelection = false
    @State private var hasStartedSession = false
    @State private var hasSavedResults = false

    @State private var showResults = false
    @State private var saveFailed = false

    // MARK: - إحصائيات اللعبة

    @State private var roundStart = Date()
    @State private var reactionTimes: [Double] = []

    @State private var correctAnswers = 0
    @State private var totalErrors = 0

    @State private var fastCorrectStreak = 0
    @State private var consecutiveErrors = 0

    // MARK: - إعدادات اللوحة

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    // 15 شكلًا في كل جولة
    private var boardTileCount: Int {
        15
    }

    // متوسط وقت الإجابة الصحيحة
    private var averageReactionTime: Double {
        guard !reactionTimes.isEmpty else {
            return 0
        }

        return reactionTimes.reduce(0, +)
            / Double(reactionTimes.count)
    }

    // حماية نتائج الاختبار السمعي
    private var safeAuditoryCorrect: Int {
        min(5, max(0, auditoryCorrectAnswers))
    }

    private var safeAuditoryWrong: Int {
        min(
            5 - safeAuditoryCorrect,
            max(0, auditoryWrongAnswers)
        )
    }

    // MARK: - الواجهة الرئيسية

    var body: some View {
        ZStack {
            Color("taskBG")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                headerView

                Spacer(minLength: 15)

                gameBoard

                Spacer(minLength: 15)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)

        // MARK: - الانتقال إلى صفحة النتائج

        .navigationDestination(isPresented: $showResults) {
            ChallengeResultsView(
                auditoryCorrectAnswers: safeAuditoryCorrect,
                visualCorrectAnswers: correctAnswers,
                visualTotalErrors: totalErrors,
                visualAverageReactionTime: averageReactionTime,
                onFinished: {
                    showResults = false
                    dismiss()
                }
            )
            .navigationBarBackButtonHidden(true)
        }

        // MARK: - الانتقال إلى MainView عند الخروج

        .navigationDestination(isPresented: $goToMainView) {
            MainView()
                .navigationBarBackButtonHidden(true)
        }

        // MARK: - تأكيد الخروج

        .alert(
            "هل أنت متأكد من الخروج؟",
            isPresented: $showExitAlert
        ) {
            Button("استمرار", role: .cancel) {}

            Button("خروج", role: .destructive) {
                goToMainView = true
            }
        } message: {
            Text("الخروج يؤدي إلى إعادة المرحلة من جديد.")
        }

        // MARK: - تنبيه تعذّر حفظ النتائج

        .alert(
            "تعذّر حفظ النتائج",
            isPresented: $saveFailed
        ) {
            Button("حسنًا", role: .cancel) {}
        } message: {
            Text(
                "لم يتم تسجيل جلسة اليوم. يمكنك مراجعة الأداء الأسبوعي لمعرفة ما تم حفظه."
            )
        }

        // MARK: - بدء الجلسة

        .onAppear {
            guard !hasStartedSession else {
                return
            }

            startSession()
        }
    }

    // MARK: - رأس الصفحة

    private var headerView: some View {
        HStack {
            Button {
                showExitAlert = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 30, weight: .semibold))
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
            .accessibilityLabel("الخروج من التحدي")

            Spacer()

            Text("تحدي الإنتباه الإنتقائي")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Color("mainBG"))
                .padding(.horizontal, 12)
                .padding(.vertical, 18)
                .background(
                    Color("box"),
                    in: RoundedRectangle(cornerRadius: 25)
                )

            Spacer()

            Image(systemName: "eye")
                .font(.system(size: 35, weight: .semibold))
                .foregroundStyle(Color("box"))
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
    }

    // MARK: - لوحة اللعبة

    private var gameBoard: some View {
        ZStack {
            Color.white

            if isFinished {
                Button {
                    showResults = true
                } label: {
                    Text(
                        saveFailed
                            ? "انتهت الجولات الخمس، لكن تعذّر حفظ النتائج.\nاضغطي هنا لعرض النتائج"
                            : "انتهت الجولات الخمس!\nاضغط هنا لعرض النتائج"
                    )
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color("mainBG"))
                    .multilineTextAlignment(.center)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

            } else {
                LazyVGrid(
                    columns: columns,
                    spacing: 60
                ) {
                    ForEach(boardTiles) { tile in
                        Button {
                            selectShape(tile)
                        } label: {
                            ShapeView(tile: tile)
                                .frame(maxWidth: .infinity)
                                .frame(height: 42)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .disabled(isProcessingSelection)
                        .accessibilityLabel(
                            shapeAccessibilityName(tile.shape)
                        )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 580)
        .clipShape(
            RoundedRectangle(cornerRadius: 50)
        )
        .padding(.horizontal, 30)
    }
   

    private func shapeAccessibilityName(
        _ shape: GameShape
    ) -> String {
        switch shape {
        case .circle:
            return "دائرة"
        case .triangle:
            return "مثلث"
        case .square:
            return "مربع"
        }
    }

    // MARK: - بدء الجلسة

    private func startSession() {
        hasStartedSession = true

        roundNumber = 1
        isFinished = false
        isProcessingSelection = false
        hasSavedResults = false
        saveFailed = false

        reactionTimes = []
        correctAnswers = 0
        totalErrors = 0

        fastCorrectStreak = 0
        consecutiveErrors = 0

        generateChallenge()
    }

    // MARK: - إنشاء الجولة

    private func generateChallenge() {
        targetShape = GameShape.allCases.randomElement()
            ?? .triangle

        let distractors = GameShape.allCases
            .filter { $0 != targetShape }
            .shuffled()

        let distractorCount = boardTileCount - 1
        var newTiles: [GameTile] = []

        // نسخة واحدة فقط من الشكل المطلوب
        newTiles.append(
            GameTile(
                shape: targetShape,
                colorIndex: Int.random(in: 0...1)
            )
        )

        // زيادة تنوع الأشكال المشتتة في المستويات الأعلى
        let useTwoDistractors =
            difficultyLevel >= 3 && distractorCount >= 2

        if useTwoDistractors {
            let firstShape = distractors[0]
            let secondShape = distractors[1]

            let firstCount = Int.random(
                in: 1...(distractorCount - 1)
            )

            let secondCount = distractorCount - firstCount

            for _ in 0..<firstCount {
                newTiles.append(
                    GameTile(
                        shape: firstShape,
                        colorIndex: Int.random(in: 0...1)
                    )
                )
            }

            for _ in 0..<secondCount {
                newTiles.append(
                    GameTile(
                        shape: secondShape,
                        colorIndex: Int.random(in: 0...1)
                    )
                )
            }

        } else {
            let distractorShape = distractors[0]

            for _ in 0..<distractorCount {
                newTiles.append(
                    GameTile(
                        shape: distractorShape,
                        colorIndex: Int.random(in: 0...1)
                    )
                )
            }
        }

        // خلط مواقع الأشكال
        boardTiles = newTiles.shuffled()

        roundStart = Date()
        isProcessingSelection = false
    }

    // MARK: - اختيار الشكل

    private func selectShape(_ tile: GameTile) {
        guard
            !isFinished,
            !isProcessingSelection,
            boardTiles.contains(where: { $0.id == tile.id })
        else {
            return
        }

        isProcessingSelection = true

        let elapsed = max(
            0,
            Date().timeIntervalSince(roundStart)
        )

        if tile.shape == targetShape {

            // الإجابة صحيحة
            correctAnswers += 1
            reactionTimes.append(elapsed)

            consecutiveErrors = 0

            if elapsed <= 2.5 {
                fastCorrectStreak += 1
            } else {
                fastCorrectStreak = 0
            }

            // زيادة الصعوبة بعد إجابتين سريعتين
            if fastCorrectStreak >= 2 {
                difficultyLevel = min(
                    difficultyLevel + 1,
                    6
                )

                fastCorrectStreak = 0
            }

        } else {

            // الإجابة خاطئة
            totalErrors += 1
            consecutiveErrors += 1
            fastCorrectStreak = 0

            // تخفيف الصعوبة بعد خطأين متتاليين
            if consecutiveErrors >= 2 {
                difficultyLevel = max(
                    difficultyLevel - 1,
                    0
                )

                consecutiveErrors = 0
            }
        }

        // الانتقال للجولة التالية أو إنهاء التحدي
        if roundNumber < 5 {
            roundNumber += 1
            generateChallenge()
        } else {
            finishSession()
        }
    }

    // MARK: - حفظ الجلسة المكتملة

    private func finishSession() {
        guard !hasSavedResults else {
            return
        }

        isFinished = true
        isProcessingSelection = true
        hasSavedResults = true

        let defaults = UserDefaults.standard

        let stepsWalked = max(
            0,
            defaults.integer(
                forKey: "nbeehPendingStorySteps"
            )
        )

        let today = Calendar.current.startOfDay(
            for: Date()
        )

        let session = DailyPerformance(
            date: today,
            steps: stepsWalked,
            auditoryCorrect: safeAuditoryCorrect,
            auditoryTotal: safeAuditoryCorrect + safeAuditoryWrong,
            visualCorrect: correctAnswers,
            visualTotal: 5,
            isCompleted: true
        )

        let saved = performance.save(session)

        if saved {
            progress.completeDailyMission()
        } else {
            saveFailed = true
        }

        // منع استخدام الخطوات مرة أخرى
        defaults.removeObject(
            forKey: "nbeehPendingStorySteps"
        )

        #if DEBUG
        print("Visual session completed")
        print("Auditory correct: \(safeAuditoryCorrect)")
        print("Auditory wrong: \(safeAuditoryWrong)")
        print("Visual correct: \(correctAnswers)")
        print("Visual errors: \(totalErrors)")
        print("Average reaction time: \(averageReactionTime)")
        print("Steps recorded: \(stepsWalked)")
        print("Saved performance: \(saved)")
        #endif
    }
}

// MARK: - رسم الأشكال

private struct ShapeView: View {
    let tile: GameTile

    var body: some View {
        GeometryReader { geometry in
            let side = min(
                geometry.size.width * 0.85,
                geometry.size.height * 0.9
            )

            Group {
                switch tile.shape {
                case .circle:
                    Circle()
                        .fill(shapeColor)

                case .triangle:
                    Triangle()
                        .fill(shapeColor)

                case .square:
                    Rectangle()
                        .fill(shapeColor)
                }
            }
            .frame(width: side, height: side)
            .frame(
                width: geometry.size.width,
                height: geometry.size.height
            )
        }
    }

    private var shapeColor: Color {
        tile.colorIndex == 0
            ? Color("botton")
            : Color("taskBG")
    }
}

// MARK: - رسم المثلث

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(
            to: CGPoint(
                x: rect.midX,
                y: rect.minY
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.maxX,
                y: rect.maxY
            )
        )

        path.addLine(
            to: CGPoint(
                x: rect.minX,
                y: rect.maxY
            )
        )

        path.closeSubpath()

        return path
    }
}

// MARK: - المعاينة

#Preview {
    NavigationStack {
        VisualAttentionGame()
    }
}
