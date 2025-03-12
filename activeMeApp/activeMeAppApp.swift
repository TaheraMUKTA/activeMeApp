//
//  activeMeAppApp.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Firebase
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct activeMeAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSplashScreen = true
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                        }
                    
                } else {
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
            .environmentObject(viewModel)
        }
    }
}
