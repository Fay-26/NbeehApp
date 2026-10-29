//
//  AuditoryAudioManager.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import Combine
import Foundation
import AVFoundation


@MainActor
final class AuditoryAudioManager: ObservableObject {
@Published private(set) var isPlaying = false
@Published private(set) var errorMessage: String?


private var player: AVAudioPlayer?


func playSound(named fileName: String) {
stopSound()
errorMessage = nil


guard let url = Bundle.main.url(
forResource: fileName,
withExtension: "mp3"
) else {
errorMessage = "لم يتم العثور على الملف الصوتي: \(fileName).mp3"
return
}


do {
let session = AVAudioSession.sharedInstance()
try session.setCategory(.playback, mode: .default)
try session.setActive(true)


let audioPlayer = try AVAudioPlayer(contentsOf: url)
audioPlayer.prepareToPlay()


guard audioPlayer.play() else {
errorMessage = "تعذر تشغيل الصوت."
return
}


player = audioPlayer
isPlaying = true
} catch {
errorMessage = "تعذر تشغيل الصوت: \(error.localizedDescription)"
}
}


func stopSound() {
player?.stop()
player = nil
isPlaying = false
}
}
