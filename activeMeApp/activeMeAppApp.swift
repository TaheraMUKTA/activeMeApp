//
//  activeMeAppApp.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import RevenueCat

// Custom AppDelegate to configure Firebase when the app launches.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()    // Initialize Firebase SDK
        return true
    }
}

@main
struct activeMeAppApp: App {
    // AppDelegate Integration
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplashScreen = true
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    @StateObject var viewModel = AuthViewModel()
    @StateObject var weatherViewModel = WeatherViewModel()
    
    
    init() {
        Purchases.logLevel = .debug      // Enable debug logs for RevenueCat (for testing)
        // Configure RevenueCat with my public API key
        Purchases.configure(withAPIKey: "appl_fYRqoZaGCpGhSSsKsEATbfAORYk")
    }
    
    // MARK: - App Entry Point
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Splash screen animation on launch
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            // Automatically dismiss splash after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                        }
                } else {
                    // Show FitnessTabView if user is logged in, otherwise show SignInView
                    if viewModel.userSession != nil {
                        FitnessTabView()
                            .environmentObject(viewModel)
                            .opacity(showSplashScreen ? 0 : 1)
                            
                    } else {
                        SignInView()
                            .environmentObject(viewModel)
                            .opacity(showSplashScreen ? 0 : 1)
                    }
                }
            }
            .onAppear {
                // Fetch current RevenueCat subscription status when app launches
                Purchases.shared.getCustomerInfo { customerInfo, error in
                    if let entitlement = customerInfo?.entitlements["Subscription"] {
                        let isActive = entitlement.isActive
                        DispatchQueue.main.async {
                            self.isPremiumUser = isActive    // Update AppStorage for use in UI
                        }
                        // Optionally sync with Firestore backend
                        Task {
                            await AuthViewModel().updateSubscriptionStatusInFirestore(isActive: isActive)
                        }
                    }
                }
            }
            // Share view models across app screens
            .environmentObject(viewModel)
            .environmentObject(weatherViewModel)
        }
    }
}
