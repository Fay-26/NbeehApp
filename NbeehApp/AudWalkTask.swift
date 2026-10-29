//
//  AudWalkTask.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//
import SwiftUI
import CoreMotion
import AVFoundation

struct AudWalkTask: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var progress = UserProgress.shared
    @StateObject private var performance = PerformanceStore.shared

    @State private var currentStepGoal = 1000
    @State private var remainingSteps = 1000
    @State private var stepsWalked = 0

    @State private var correctCount = 0
    @State private var incorrectCount = 0
    @State private var missedCount = 0

    // Number of non-target sounds correctly ignored.
    @State private var correctRejections = 0

    @State private var isRoundRunning = false
    @State private var hasStartedWalking = false
    @State private var isTrialActive = false
    @State private var isCurrentSoundTarget = false
    @State private var didRespond = false

    @State private var nextCueStep = 50
    @State private var activeTrialID = UUID()

    @State private var showExitConfirmation = false
    @State private var showResults = false
    @State private var showStepError = false
    @State private var showAudioError = false

    @State private var audioPlayer: AVAudioPlayer?
    @State private var trialTask: Task<Void, Never>?

    private let pedometer = CMPedometer()
    private let stepsBetweenSounds = 50

    // All completed sound trials, including correct rejections.
    private var totalAttempts: Int {
        correctCount + incorrectCount + missedCount + correctRejections
    }

    private var auditoryCorrectTotal: Int {
        correctCount + correctRejections
    }

    // MARK: - Start Challenge

    private func startChallenge() {
        guard !isRoundRunning else { return }

        guard CMPedometer.isStepCountingAvailable() else {
            showStepError = true
            return
        }

        stopAudio()
        trialTask?.cancel()

        currentStepGoal = max(1, progress.dailyStepGoal)
        remainingSteps = currentStepGoal
        stepsWalked = 0

        correctCount = 0
        incorrectCount = 0
        missedCount = 0
        correctRejections = 0

        hasStartedWalking = false
        nextCueStep = stepsBetweenSounds
        isTrialActive = false
        didRespond = false
        isRoundRunning = true

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio setup error: \(error.localizedDescription)")
        }

        pedometer.startUpdates(from: Date()) { data, error in
            guard let data, error == nil else {
                return
            }

            let steps = max(0, data.numberOfSteps.intValue)

            DispatchQueue.main.async {
                guard isRoundRunning else { return }

                stepsWalked = min(steps, currentStepGoal)
                remainingSteps = max(0, currentStepGoal - steps)

                if steps > 0 {
                    hasStartedWalking = true
                }

                if steps >= currentStepGoal {
                    finishChallenge()
                    return
                }

                if hasStartedWalking,
                   steps >= nextCueStep,
                   !isTrialActive {
                    playNextSound()
                }
            }
        }
    }

    // MARK: - Play Sound Trial

    private func playNextSound() {
        guard isRoundRunning, !isTrialActive else { return }

        let soundNames = ["bird", "dog", "cat"]
        let soundName = soundNames.randomElement() ?? "bird"

        isCurrentSoundTarget = soundName == "bird"
        didRespond = false
        isTrialActive = true

        let trialID = UUID()
        activeTrialID = trialID

        guard playSound(named: soundName) else {
            isTrialActive = false
            activeTrialID = UUID()
            nextCueStep += stepsBetweenSounds
            showAudioError = true
            return
        }

        trialTask?.cancel()

        trialTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000)
            } catch {
                return
            }

            guard !Task.isCancelled else { return }

            finishTrial(trialID: trialID)
        }
    }

    private func playSound(named name: String) -> Bool {
        guard let url = Bundle.main.url(
            forResource: name,
            withExtension: "mp3"
        ) else {
            print("Missing audio file: \(name).mp3")
            return false
        }

        do {
            audioPlayer?.stop()

            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()

            audioPlayer = player
            return player.play()
        } catch {
            print("Audio playback error: \(error.localizedDescription)")
            return false
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }

    // MARK: - Finish Trial

    private func finishTrial(trialID: UUID) {
        guard activeTrialID == trialID,
              isTrialActive,
              isRoundRunning else {
            return
        }

        stopAudio()

        if isCurrentSoundTarget {
            if !didRespond {
                missedCount += 1
            }
        } else {
            // Ignoring dog/cat sounds is the correct response.
            if !didRespond {
                correctRejections += 1
            }
        }

        isTrialActive = false
        didRespond = false
        nextCueStep += stepsBetweenSounds
    }

    // MARK: - Record Response

    private func recordResponse() {
        guard isRoundRunning,
              isTrialActive,
              !didRespond else {
            return
        }

        didRespond = true

        if isCurrentSoundTarget {
            correctCount += 1
        } else {
            incorrectCount += 1
        }
    }

    // MARK: - Finish Challenge

    private func finishChallenge() {
        guard isRoundRunning else { return }

        isRoundRunning = false
        pedometer.stopUpdates()

        trialTask?.cancel()
        trialTask = nil

        // Finalize the active trial exactly once.
        if isTrialActive {
            if isCurrentSoundTarget {
                if !didRespond {
                    missedCount += 1
                }
            } else if !didRespond {
                correctRejections += 1
            }
        }

        isTrialActive = false
        activeTrialID = UUID()
        didRespond = false

        stopAudio()

        remainingSteps = 0
        stepsWalked = currentStepGoal

        let session = DailyPerformance(
            date: Date(),
            steps: stepsWalked,
            auditoryCorrect: auditoryCorrectTotal,
            auditoryTotal: totalAttempts,
            visualCorrect: 0,
            visualTotal: 0,
            isCompleted: true
        )

        let saved = performance.save(session)

        if saved {
            progress.completeDailyMission()
        }

        showResults = true
    }

    // MARK: - Cancel Challenge

    private func cancelChallenge() {
        isRoundRunning = false
        activeTrialID = UUID()

        trialTask?.cancel()
        trialTask = nil

        pedometer.stopUpdates()
        stopAudio()

        dismiss()
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.black)
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
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)

            VStack(spacing: 10) {
                HStack {
                    Spacer()

                    Text("مهمتك:")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("textbig"))
                }

                Text("انتبه لصوت العصفور")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("textbig"))
                    .frame(maxWidth: .infinity)

                Text("لما تسمع صوت العصفور اضغط الزر")
                    .font(.system(size: 12))
                    .foregroundStyle(Color("textbig"))
                    .frame(maxWidth: .infinity)

                Text("الهدف: \(currentStepGoal.formatted()) خطوة")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color("textbig"))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding(.horizontal, 8)

            VStack(spacing: 8) {
                Text("\(remainingSteps.formatted())")
                    .font(.system(size: 68, weight: .bold))
                    .foregroundStyle(Color("mainBG"))

                Text("الخطوات المتبقية")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("mainBG"))
            }
            .frame(width: 277, height: 209)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "arrowshape.down")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color("mainBG"))
                    .padding(16)
            }
            .background(
                Color("box"),
                in: RoundedRectangle(cornerRadius: 30)
            )
            .padding(.top, 40)
            .frame(maxWidth: .infinity)

            Button {
                recordResponse()
            } label: {
                Text("سمعت")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("textbig"))
                    .frame(width: 220, height: 70)
                    .background(
                        Color("botton"),
                        in: RoundedRectangle(cornerRadius: 30)
                    )
            }
            .disabled(
                !isRoundRunning ||
                !isTrialActive ||
                didRespond
            )
            .opacity(
                isRoundRunning && isTrialActive && !didRespond
                    ? 1
                    : 0.5
            )
            .padding(.top, 45)

            Spacer(minLength: 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("taskBG"))
        .onAppear {
            startChallenge()
        }
        .onDisappear {
            isRoundRunning = false
            activeTrialID = UUID()

            trialTask?.cancel()
            trialTask = nil

            pedometer.stopUpdates()
            stopAudio()
        }
        .confirmationDialog(
            "هل أنت متأكد من الخروج؟",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("الاستمرار", role: .cancel) {
                // Continue the challenge without resetting progress.
            }

            Button("تأكيد الخروج", role: .destructive) {
                cancelChallenge()
            }
        } message: {
            Text("الخروج يؤدي إلى إعادة المرحلة من جديد")
        }
        .alert("اكتمل التحدي!", isPresented: $showResults) {
            Button("متابعة", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("""
            أحسنت! أكملت \(currentStepGoal.formatted()) خطوة.

            الإجابات الصحيحة: \(correctCount + correctRejections)
            الإجابات الخاطئة: \(incorrectCount)
            الأصوات المستهدفة التي فاتتك: \(missedCount)

            هدفك القادم يعتمد على مستواك الحالي.
            """)
        }
        .alert("عداد الخطوات غير متاح", isPresented: $showStepError) {
            Button("حسنًا", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("لا يمكن الوصول إلى عداد الخطوات على هذا الجهاز.")
        }
        .alert("تعذر تشغيل الصوت", isPresented: $showAudioError) {
            Button("حسنًا", role: .cancel) {}
        } message: {
            Text("تأكد من إضافة ملفات bird.mp3 و dog.mp3 و cat.mp3 إلى موارد التطبيق.")
        }
    }
}

#Preview {
    AudWalkTask()
}
