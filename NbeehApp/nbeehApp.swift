//
//  NbeehAppApp.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//
import SwiftUI
@main
struct nbeehApp: App {
@StateObject private var userProgress = UserProgress.shared
var body: some Scene {
WindowGroup {
LandingView()
.environmentObject(userProgress)
}
}
}
