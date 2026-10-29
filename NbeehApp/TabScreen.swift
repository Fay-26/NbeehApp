//
//  TabScreen.swift
//  NbeehApp
//
//  Created by Fay Alabdulqader on 29/10/2026.
//

import SwiftUI
struct TabScreen: View {
@State private var selectedTab = 1
var body: some View {
TabView(selection: $selectedTab) {
NavigationStack {
WeeklyPerformanceView()
}
.tabItem {
Label("الأداء", systemImage: "chart.bar.fill")
}
.tag(0)
NavigationStack {
MainView()
}
.tabItem {
Label("الأساسية", systemImage: "house.fill")
}
.tag(1)
}
.preferredColorScheme(.dark)
.tint(Color("botton"))
}
}
#Preview {
TabScreen()
}
