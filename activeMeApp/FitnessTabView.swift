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
        let customGreen = UIColor(red: 15/255, green: 174/255, blue: 1/255, alpha: 1) // 1CB60E in RGB
        
        appearance.stackedLayoutAppearance.selected.iconColor = customGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [ .foregroundColor: customGreen]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = customGreen
        
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
            TopPerformersView(showPage: .constant(false))
                .tag("Top Performers")
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Top Performers")
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
struct FitnessTabView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessTabView()
    }
}

