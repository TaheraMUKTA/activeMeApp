//
//  activeMeAppApp.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

@main
struct activeMeAppApp: App {
    @State private var showSplashScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                FitnessTabView()
                    .opacity(showSplashScreen ? 0 : 1) // Hide Main View initially
                            
                if showSplashScreen {
                    SplashScreenView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}
