//
//  FitnessTabView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import RevenueCat
import FirebaseAuth
import FirebaseFirestore

struct FitnessTabView: View {
    
    @AppStorage("userName") var userName: String?
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    @State private var hasCheckedUser = false    // Flag to prevent re-checking
    @State var selectedTab = "Home"     // Home will be the default tab
    @State var showBoardPage = false
    @State var isPremium = false
    
    // MARK: - Tab Bar Appearance Customization
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        let customGreen = UIColor(red: 15/255, green: 174/255, blue: 1/255, alpha: 1) // 1CB60E in RGB
        
        // Customize selected tab icon and text color
        appearance.stackedLayoutAppearance.selected.iconColor = customGreen
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [ .foregroundColor: customGreen]
        // Apply appearance globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = customGreen
        
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tag("Home")
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            // Charts Tab
            ChartsView()
                .tag("Charts")
                .tabItem {
                    Image(systemName: "chart.bar.xaxis.ascending")
                    Text("Charts")
                }
            // Top Performers Tab
            if showBoardPage {
                BoardPageView(showPage: $showBoardPage)
                    .tag("Top Performers")
                    .tabItem {
                        Image(systemName: "list.star")
                            Text("Top Performers")
                    }
            } else {
                TopPerformersView(showPage: $showBoardPage)
                    .tag("Top Performers")
                    .tabItem {
                        Image(systemName: "list.star")
                        Text("Top Performers")
                    }
                    .onAppear {
                        checkIfNewUser()    // Check if onboarding page should be shown
                    }
            }
            // Profile Tab
            ProfileView()
                .tag("Profile")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .onAppear {
            // Fetch current subscription status from RevenueCat
            Purchases.shared.getCustomerInfo { customerInfo, error in
                isPremium = customerInfo?.entitlements["Subscription"]?.isActive == true 
            }
        }
    }
    
    // MARK: - New User Check

    // if the logged in user is new and hasn't accepted the terms than show BoardPageView
    func checkIfNewUser() {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user logged in.")
            return
        }

        let acceptedTerms = UserDefaults.standard.bool(forKey: "acceptedTerms")

        if acceptedTerms {
            print("DEBUG: User has already accepted terms or showBoardPage is already active.")
            return
        }

        let userRef = Firestore.firestore().collection("users").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("DEBUG: Existing user found in Firestore but has NOT accepted terms.")
                DispatchQueue.main.async {
                    self.showBoardPage = true
                }
            } else {
                print("DEBUG: New user detected, showing BoardPageView.")
                DispatchQueue.main.async {
                    self.showBoardPage = true
                }
            }
        }
    }
}

struct FitnessTabView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(WeatherViewModel())
    }
}
