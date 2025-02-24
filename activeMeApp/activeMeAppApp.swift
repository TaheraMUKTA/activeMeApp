//
//  activeMeAppApp.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Firebase

@main
struct activeMeAppApp: App {
    @State private var showSplashScreen = true
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
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
