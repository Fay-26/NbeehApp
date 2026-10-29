//
//  AudWalkStory.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI
import CoreMotion
import AVFoundation

struct AudWalkStory: View {

    @StateObject private var progress = UserProgress.shared

    @State private var remainingSteps = 1000
    @State private var stepsWalked = 0

    @State private var isPlaying = false
    @State private var storyFinished = false
    @State private var stepGoalReached = false
    @State private var challengeFinished = false
    @State private var hasStartedStepCounting = false

    @State private var showExitConfirmation = false
    @State private var showStepError = false
    @State private var showAudioError = false

    @State private var navigateToMovingPageStory = false
    @State private var navigateToMainView = false

    @State private var audioPlayer: AVAudioPlayer?
    @State private var audioDelegate: StoryAudioDelegate?

    private let pedometer = CMPedometer()

    private var dailyGoal: Int {
        max(1, progress.dailyStepGoal)
    }

    // MARK: - Step Counting

    private func startStepCounting() {
        guard !hasStartedStepCounting else { return }

        guard CMPedometer.isStepCountingAvailable() else {
            showStepError = true
            return
        }

        hasStartedStepCounting = true

        pedometer.startUpdates(from: Date()) { data, error in
            guard let data, error == nil else {
                DispatchQueue.main.async {
                    guard !challengeFinished else { return }
                    showStepError = true
                }
                return
            }

            let steps = max(0, data.numberOfSteps.intValue)

            DispatchQueue.main.async {
                guard !challengeFinished else { return }

                stepsWalked = min(steps, dailyGoal)
                remainingSteps = max(0, dailyGoal - steps)

                if steps >= dailyGoal {
                    stepGoalReached = true
                    checkChallengeCompletion()
                }
            }
        }
    }

    // MARK: - Story Audio

    private func playStory() {
        guard !isPlaying,
              !storyFinished,
              !challengeFinished else {
            return
        }

        guard let url = Bundle.main.url(
            forResource: "سارة",
            withExtension: "m4a"
        ) else {
            showAudioError = true
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )

            try AVAudioSession.sharedInstance().setActive(true)

            let delegate = StoryAudioDelegate()
            audioDelegate = delegate

            delegate.onFinish = { successfully in
                DispatchQueue.main.async {
                    guard !challengeFinished else { return }

                    isPlaying = false
                    audioPlayer = nil

                    if successfully {
                        storyFinished = true
                        checkChallengeCompletion()
                    } else {
                        showAudioError = true
                    }
                }
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = delegate
            player.prepareToPlay()

            guard player.play() else {
                audioDelegate?.onFinish = nil
                audioDelegate = nil
                showAudioError = true
                return
            }

            audioPlayer = player
            isPlaying = true

            // يبدأ عداد الخطوات عند بدء القصة
            startStepCounting()

        } catch {
            print("Story playback error: \(error.localizedDescription)")
            showAudioError = true
        }
    }

    private func stopStory() {
        audioDelegate?.onFinish = nil
        audioPlayer?.delegate = nil
        audioPlayer?.stop()

        audioPlayer = nil
        audioDelegate = nil
        isPlaying = false
    }

    // MARK: - Complete Walking Stage

    private func checkChallengeCompletion() {
        guard !challengeFinished,
              storyFinished,
              stepGoalReached else {
            return
        }

        challengeFinished = true

        pedometer.stopUpdates()
        stopStory()

        // حفظ الخطوات لاستخدامها في تسجيل الأداء لاحقًا
        UserDefaults.standard.set(
            stepsWalked,
            forKey: "nbeehPendingStorySteps"
        )

        // الانتقال إلى صفحة إكمال المرحلة
        navigateToMovingPageStory = true
    }

    // MARK: - Exit Challenge

    private func exitChallenge() {
        challengeFinished = true

        pedometer.stopUpdates()
        stopStory()

        hasStartedStepCounting = false

        UserDefaults.standard.removeObject(
            forKey: "nbeehPendingStorySteps"
        )

        // الانتقال إلى الصفحة الرئيسية
        navigateToMainView = true
    }

    // MARK: - Interface

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header and Exit Button
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

                    Text("تحدي الانتباه المستمر")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(Color("mainBG"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 18)
                        .background(
                            Color("box"),
                            in: RoundedRectangle(cornerRadius: 20)
                        )

                    Spacer()

                    Image(systemName: "headphones")
                        .font(.system(size: 35, weight: .semibold))
                        .foregroundStyle(Color("box"))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)

                // Task Instructions
                VStack(spacing: 10) {
                    HStack {
                        Spacer()

                        Text("مهمتك:")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Color("textbig"))
                    }

                    Text("استمع إلى قصة سارة")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color("textbig"))
                        .frame(maxWidth: .infinity)

                    Text("امشِ أثناء الاستماع حتى تكمل هدف الخطوات")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("textbig"))
                        .frame(maxWidth: .infinity)

                    Text("الهدف: \(dailyGoal.formatted()) خطوة")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color("textbig"))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
                .padding(.horizontal, 8)

                // Remaining Steps
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

                // Play Story Button
                Button {
                    playStory()
                } label: {
                    Text(
                        isPlaying
                            ? "القصة قيد التشغيل"
                            : storyFinished
                                ? "اكتملت القصة"
                                : "استمع إلى القصة"
                    )
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color("textbig"))
                    .frame(width: 260, height: 70)
                    .background(
                        Color("botton"),
                        in: RoundedRectangle(cornerRadius: 30)
                    )
                }
                .disabled(isPlaying || storyFinished || challengeFinished)
                .opacity(
                    isPlaying || storyFinished || challengeFinished
                        ? 0.7
                        : 1
                )
                .padding(.top, 45)

                // Progress Messages
                if storyFinished && !stepGoalReached {
                    Text("أكملت الاستماع! واصل المشي لإكمال هدفك.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("textbig"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)

                } else if stepGoalReached && !storyFinished {
                    Text("أكملت الخطوات! استمر في الاستماع حتى تنتهي القصة.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color("textbig"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("taskBG"))
            .navigationBarBackButtonHidden(true)

            .onAppear {
                remainingSteps = dailyGoal
            }

            .onDisappear {
                pedometer.stopUpdates()
                stopStory()
            }

            // الانتقال بعد اكتمال القصة وهدف الخطوات
            .navigationDestination(
                isPresented: $navigateToMovingPageStory
            ) {
                movingPageStory()
                    .navigationBarBackButtonHidden(true)
            }

            // الانتقال إلى MainView عند اختيار خروج
            .navigationDestination(
                isPresented: $navigateToMainView
            ) {
                MainView()
                    .navigationBarBackButtonHidden(true)
            }

            // MARK: - Exit Confirmation

            .alert(
                "هل أنت متأكدة من الخروج؟",
                isPresented: $showExitConfirmation
            ) {
                Button("استمرار", role: .cancel) {
                    // إغلاق التنبيه فقط.
                    // يبقى التحدي والخطوات والقصة كما هي.
                }

                Button("خروج", role: .destructive) {
                    exitChallenge()
                }
            } message: {
                Text("الخروج يؤدي إلى إعادة المرحلة من جديد")
            }

            // MARK: - Step Counter Error

            .alert(
                "عداد الخطوات غير متاح",
                isPresented: $showStepError
            ) {
                Button("حسنًا", role: .cancel) {
                    exitChallenge()
                }
            } message: {
                Text("لا يمكن الوصول إلى عداد الخطوات على هذا الجهاز.")
            }

            // MARK: - Audio Error

            .alert(
                "تعذر تشغيل القصة",
                isPresented: $showAudioError
            ) {
                Button("إعادة المحاولة", role: .cancel) {}

                Button("خروج", role: .destructive) {
                    exitChallenge()
                }
            } message: {
                Text("تأكد من إضافة ملف سارة.m4a إلى موارد التطبيق.")
            }
        }
    }
}

// MARK: - Audio Delegate

private final class StoryAudioDelegate: NSObject, AVAudioPlayerDelegate {

    var onFinish: ((Bool) -> Void)?

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        onFinish?(flag)
    }
}


#Preview {
    AudWalkStory()
}
