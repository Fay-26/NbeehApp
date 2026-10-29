//
//  PerformanceStore.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import Foundation
import Combine

// MARK: - نموذج الأداء اليومي

struct DailyPerformance: Codable, Identifiable {

    var id: UUID = UUID()
    var date: Date
    var steps: Int

    var auditoryCorrect: Int
    var auditoryTotal: Int

    var visualCorrect: Int
    var visualTotal: Int

    var isCompleted: Bool

    var totalCorrect: Int {
        max(0, auditoryCorrect) + max(0, visualCorrect)
    }

    var totalAttempts: Int {
        max(0, auditoryTotal) + max(0, visualTotal)
    }

    var accuracy: Double? {
        guard totalAttempts > 0 else {
            return nil
        }

        return min(
            100,
            max(
                0,
                Double(totalCorrect) / Double(totalAttempts) * 100
            )
        )
    }
}

// MARK: - مخزن الأداء

@MainActor
final class PerformanceStore: ObservableObject {

    static let shared = PerformanceStore()

    @Published private(set) var sessions: [DailyPerformance] = []

    private let storageKey = "nbeeh.dailyPerformance.v1"

    private init() {
        load()
    }

    // MARK: - التحقق من صحة الجلسة

    private func isValid(_ session: DailyPerformance) -> Bool {
        guard session.isCompleted else {
            return false
        }

        guard
            session.steps >= 0,
            session.auditoryCorrect >= 0,
            session.auditoryTotal >= 0,
            session.visualCorrect >= 0,
            session.visualTotal >= 0
        else {
            return false
        }

        guard
            session.auditoryCorrect <= session.auditoryTotal,
            session.visualCorrect <= session.visualTotal,
            session.totalAttempts > 0
        else {
            return false
        }

        return true
    }

    // MARK: - حفظ الجلسة

    /// يسمح بحفظ جلسة مكتملة واحدة فقط في اليوم المحلي.
    @discardableResult
    func save(_ session: DailyPerformance) -> Bool {
        let calendar = Calendar.current

        guard
            calendar.isDateInToday(session.date),
            isValid(session)
        else {
            return false
        }

        let alreadySavedToday = sessions.contains { savedSession in
            calendar.isDate(
                savedSession.date,
                inSameDayAs: session.date
            ) && savedSession.isCompleted
        }

        guard !alreadySavedToday else {
            return false
        }

        var updatedSessions = sessions

        updatedSessions.removeAll { savedSession in
            calendar.isDate(
                savedSession.date,
                inSameDayAs: session.date
            )
        }

        updatedSessions.append(session)

        updatedSessions.sort {
            $0.date < $1.date
        }

        // نُرمّز البيانات قبل تغيير الحالة المنشورة.
        guard let data = try? JSONEncoder().encode(updatedSessions) else {
            return false
        }

        // UserDefaults لا يوفر تأكيدًا على الكتابة إلى القرص،
        // لكن set يحدّث قيمة التخزين المتاحة للتطبيق.
        UserDefaults.standard.set(data, forKey: storageKey)

        // لا نعلن نجاح الحفظ إلا بعد تجهيز البيانات وتحديث التخزين.
        sessions = updatedSessions

        return true
    }

    // MARK: - استرجاع جلسة يوم محدد

    func session(on date: Date) -> DailyPerformance? {
        let calendar = Calendar.current

        return sessions
            .filter { savedSession in
                calendar.isDate(
                    savedSession.date,
                    inSameDayAs: date
                )
            }
            .max { $0.date < $1.date }
    }

    // MARK: - استرجاع جلسات فترة زمنية

    /// تاريخ البداية مشمول، وتاريخ النهاية غير مشمول.
    func sessions(
        from startDate: Date,
        to endDate: Date
    ) -> [DailyPerformance] {
        guard startDate < endDate else {
            return []
        }

        return sessions
            .filter { session in
                session.date >= startDate &&
                session.date < endDate &&
                session.isCompleted
            }
            .sorted {
                $0.date < $1.date
            }
    }

    // MARK: - تحميل البيانات

    private func load() {
        guard let data = UserDefaults.standard.data(
            forKey: storageKey
        ) else {
            sessions = []
            return
        }

        guard let savedSessions = try? JSONDecoder().decode(
            [DailyPerformance].self,
            from: data
        ) else {
            // لا نستبدل البيانات التالفة تلقائيًا ببيانات فارغة
            // حتى لا نمحوها قبل أن تتاح فرصة استعادتها.
            sessions = []
            return
        }

        let calendar = Calendar.current

        let validSessions = savedSessions
            .filter { isValid($0) }
            .sorted { $0.date < $1.date }

        // الاحتفاظ بسجل واحد فقط لكل يوم.
        // عند وجود تكرار، نحتفظ بالسجل الأحدث زمنيًا.
        var sessionsByDay: [Date: DailyPerformance] = [:]

        for session in validSessions {
            let day = calendar.startOfDay(for: session.date)
            sessionsByDay[day] = session
        }

        let cleanedSessions = sessionsByDay.values.sorted {
            $0.date < $1.date
        }

        sessions = cleanedSessions

        // تحديث التخزين بالنسخة المنظفة.
        _ = persist(cleanedSessions)
    }

    // MARK: - حفظ التخزين

    @discardableResult
    private func persist(
        _ sessionsToSave: [DailyPerformance]
    ) -> Bool {
        guard let data = try? JSONEncoder().encode(sessionsToSave) else {
            return false
        }

        UserDefaults.standard.set(data, forKey: storageKey)
        return true
    }
}
