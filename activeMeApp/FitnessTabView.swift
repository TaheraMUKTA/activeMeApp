//
//  FitnessTabView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct FitnessTabView: View {
    @AppStorage("userName") var userName: String?
    
    @State var selectedTab = "Home"
    @State var showPage = true
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let customGreen = UIColor(red: 28/255, green: 182/255, blue: 14/255, alpha: 1) // 1CB60E in RGB
        
        appearance.stackedLayoutAppearance.selected.iconColor = customGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: customGreen]
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ChartsDataView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("Charts")
                }
            ChampionsView(showPage: .constant(false))
                .tag("Champions")
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Champions")
                }
            ProfileView()
                .tag("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .onAppear {
            showPage = userName == nil
        }
    }
}

#Preview {
    FitnessTabView()
}
