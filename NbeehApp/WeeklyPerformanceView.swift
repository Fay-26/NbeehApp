//
//  WeeklyPerformanceView.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI

struct WeeklyPerformanceView: View {

    // MARK: - Saved Data

    @ObservedObject private var store = PerformanceStore.shared
    @State private var today = Date()

    // MARK: - Colors

    private let backgroundColor = Color("mainBG")
    private let cardColor = Color("taskBG")
    private let lightPurple = Color("box")
    private let purple = Color("botton")
    private let primaryText = Color("textbig")
    private let secondaryText = Color("textsmall")
    private let darkText = Color("textsmalldark")

    // MARK: - Calendar

    private var calendar: Calendar {
        var value = Calendar.current
        value.firstWeekday = 1
        return value
    }

    private let dayNames = [
        "الأحد",
        "الاثنين",
        "الثلاثاء",
        "الأربعاء",
        "الخميس",
        "الجمعة",
        "السبت"
    ]

    private var weekDates: [Date] {
        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: today
        ) else {
            return []
        }

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: interval.start
            )
        }
    }

    private var weeklySessions: [DailyPerformance] {
        weekDates.compactMap { date in
            guard !isFutureDay(date),
                  let session = store.session(on: date),
                  session.isCompleted else {
                return nil
            }

            return session
        }
    }

    private var weeklyData: [(day: String, date: Date, accuracy: Double?)] {
        weekDates.enumerated().map { index, date in
            let session = store.session(on: date)
            let isAvailableDay = !isFutureDay(date)

            let accuracy: Double? = {
                guard isAvailableDay,
                      let session,
                      session.isCompleted else {
                    return nil
                }

                return session.accuracy
            }()

            return (
                day: dayNames[index],
                date: date,
                accuracy: accuracy
            )
        }
    }

    private var completedDays: [Bool] {
        weekDates.map { date in
            guard !isFutureDay(date) else {
                return false
            }

            return store.session(on: date)?.isCompleted == true
        }
    }

    private var completedCount: Int {
        completedDays.filter { $0 }.count
    }

    private var steps: Int {
        weeklySessions.reduce(0) { total, session in
            total + max(0, session.steps)
        }
    }

    private var weeklyAccuracy: Double? {
        let correct = weeklySessions.reduce(0) { total, session in
            total + session.totalCorrect
        }

        let attempts = weeklySessions.reduce(0) { total, session in
            total + session.totalAttempts
        }

        guard attempts > 0 else {
            return nil
        }

        return min(
            100,
            max(0, Double(correct) / Double(attempts) * 100)
        )
    }

    private var elapsedDaysThisWeek: Int {
        weekDates.filter { !isFutureDay($0) }.count
    }

    private func isFutureDay(_ date: Date) -> Bool {
        calendar.startOfDay(for: date) >
            calendar.startOfDay(for: today)
    }

    // MARK: - Main View

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height

            let contentWidth = min(
                332,
                screenWidth - 48
            )

            let verticalScale = min(
                1,
                screenHeight / 780
            )

            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        stepsCard
                            .frame(
                                maxWidth: .infinity,
                                alignment: .trailing
                            )
                            .padding(.top, 28)

                        performanceTitle
                            .padding(
                                .top,
                                64 * verticalScale
                            )

                        weeklyChart
                            .padding(
                                .top,
                                24 * verticalScale
                            )

                        completedChallengesCard
                            .padding(
                                .top,
                                44 * verticalScale
                            )

                        attentionAccuracyCard
                            .padding(
                                .top,
                                28 * verticalScale
                            )

                        Spacer(minLength: 20)
                    }
                    .frame(width: contentWidth)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            today = Date()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            today = Date()
        }
    }

    // MARK: - Steps Card

    private var stepsCard: some View {
        HStack(spacing: 12) {
            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(steps.formatted())
                    .font(.system(size: 24, weight: .bold))

                Text("مجموع خطواتك")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(primaryText)

            Image(systemName: "shoeprints.fill")
                .font(.system(size: 20))
                .foregroundStyle(primaryText)
                .frame(width: 48, height: 48)
                .overlay {
                    Circle()
                        .stroke(purple, lineWidth: 3)
                }
        }
        .padding(.leading, 3)
        .padding(.trailing, 5)
        .frame(width: 230, height: 58)
        .background {
            RoundedRectangle(cornerRadius: 27)
                .fill(cardColor)
                .stroke(
                    lightPurple.opacity(0.4),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Title

    private var performanceTitle: some View {
        Text("أداؤك هذا الأسبوع")
            .font(.system(size: 35, weight: .bold))
            .foregroundStyle(primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        VStack(spacing: 8) {
            GeometryReader { chartGeometry in
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(
                        Array(weeklyData.enumerated()),
                        id: \.offset
                    ) { _, item in
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)

                            ZStack(alignment: .top) {
                                Rectangle()
                                    .fill(
                                        item.accuracy == nil
                                            ? purple.opacity(0.25)
                                            : purple
                                    )

                                if let accuracy = item.accuracy {
                                    Text(
                                        "\(Int(accuracy.rounded()))%"
                                    )
                                    .font(
                                        .system(
                                            size: 11,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundStyle(primaryText)
                                    .padding(.top, 4)
                                }
                            }
                            .frame(
                                height: item.accuracy.map { accuracy in
                                    max(
                                        4,
                                        chartGeometry.size.height
                                            * CGFloat(accuracy) / 100
                                    )
                                } ?? 4
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .environment(
                    \.layoutDirection,
                    .rightToLeft
                )
            }
            .frame(height: 184)
            .padding(.horizontal, 12)
            .padding(.top, 15)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .fill(lightPurple)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 25)
            )

            HStack(spacing: 8) {
                ForEach(
                    Array(weeklyData.enumerated()),
                    id: \.offset
                ) { _, item in
                    VStack(spacing: 3) {
                        Text(item.day)
                            .font(.system(size: 12))
                            .foregroundStyle(primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)

                        if calendar.isDate(
                            item.date,
                            inSameDayAs: today
                        ) {
                            Circle()
                                .fill(primaryText)
                                .frame(width: 4, height: 4)
                        } else {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .environment(
                \.layoutDirection,
                .rightToLeft
            )

            HStack(spacing: 6) {
                Circle()
                    .fill(purple.opacity(0.25))
                    .frame(width: 8, height: 8)

                Text("لا توجد نتيجة مسجلة حاليا")
                    .font(.system(size: 12))
                    .foregroundStyle(secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 16)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Completed Challenges

    private var completedChallengesCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(completedCount)/\(elapsedDaysThisWeek)")
                    .font(.system(size: 15, weight: .bold))

                Spacer()

                Text("التحديات المكتملة")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(primaryText)

            HStack(spacing: 4) {
                ForEach(
                    Array(completedDays.enumerated()),
                    id: \.offset
                ) { _, completed in
                    Image(
                        systemName: completed
                            ? "checkmark"
                            : "minus"
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("mainBG"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 24)
                    .background {
                        Capsule()
                            .fill(lightPurple)
                    }
                }
            }
            .environment(
                \.layoutDirection,
                .rightToLeft
            )
            HStack {
                Spacer()

                Text(
                    "\(completedCount) أيام مكتملة من \(elapsedDaysThisWeek) أيام حتى الآن"
                )
                .font(.system(size: 10))
                .foregroundStyle(primaryText)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(cardColor)
                .stroke(primaryText, lineWidth: 1)
        }
        .padding(.top, -15)
    }

    // MARK: - Attention Accuracy

    private var attentionAccuracyCard: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 4) {
                Text("كفاءة الإنتباه")
                    .font(.system(size: 16, weight: .bold))

                Text("تقيس سرعة استجابتك ودقتها أثناء التحديات")
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("متوسط هذا الأسبوع")
                    .font(.system(size: 10))
            }
            .foregroundStyle(primaryText)

            ZStack {
                Circle()
                    .stroke(
                        lightPurple.opacity(0.5),
                        lineWidth: 6
                    )

                Circle()
                    .trim(
                        from: 0,
                        to: CGFloat(weeklyAccuracy ?? 0) / 100
                    )
                    .stroke(
                        purple,
                        style: StrokeStyle(
                            lineWidth: 6,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))

                Text(
                    weeklyAccuracy.map {
                        "\(Int($0.rounded()))%"
                    } ?? "—"
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(primaryText)
            }
            .frame(width: 64, height: 64)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 85)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(cardColor)
                .stroke(primaryText, lineWidth: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    WeeklyPerformanceView()
}
