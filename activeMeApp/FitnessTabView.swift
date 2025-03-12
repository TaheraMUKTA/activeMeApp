//
//  FitnessTabView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FitnessTabView: View {
    
    @AppStorage("userName") var userName: String?
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var hasCheckedUser = false
    
    @State var selectedTab = "Home"
    @State var showBoardPage = false
    
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

            ChartsView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("Charts")
                }
            TopPerformersView(showPage: $showBoardPage)
                .tag("Top Performers")
                .tabItem {
                    Image(systemName: "list.star")
                    Text("Top Performers")
                }
                .onAppear {
                    checkIfNewUser()
                }
            
            ProfileView()
                .tag("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }
    
    func checkIfNewUser() {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user logged in.")
            return
        }

        let acceptedTerms = UserDefaults.standard.bool(forKey: "acceptedTerms")

        if acceptedTerms {
            print("DEBUG: User has already accepted terms. No need to show BoardPageView.")
            return
        }

        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("DEBUG: Existing user found in Firestore but has NOT accepted terms.")
                DispatchQueue.main.async {
                    showBoardPage = true
                }
            } else {
                print("DEBUG: New user detected, showing BoardPageView.")
                DispatchQueue.main.async {
                    showBoardPage = true
                }
            }
        }
    }

    
    
}
struct FitnessTabView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessTabView()
            .environmentObject(AuthViewModel())
    }
}
