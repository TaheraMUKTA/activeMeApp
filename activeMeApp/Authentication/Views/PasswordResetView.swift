//
//  PasswordResetView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct PasswordResetView: View {
    @State private var showLottie = false
    
    var body: some View {
        // Adaptive color for dark/light mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        VStack {
            Spacer().frame(height: 30)

            if showLottie {
                LottieView(animationName: "dumbbell", width: 150, height: 150)
                    .frame(width: 170, height: 120)
                    .padding(.bottom, -20)
                    .padding(.top, 10)
            }

            Spacer().frame(height: 70)
            // Checkmark icon for success
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                .padding()

            Spacer().frame(height: 20)

            Text("Password Reset")
                .font(.title)
                .bold()
                        

            Spacer().frame(height: 60)

            Text("Your password has been successfully reset.")
                .font(.headline)
                .foregroundColor(adaptiveColor.opacity(0.7))

            Spacer().frame(height: 5)

            Text("Click below to login")
                .font(.body)
                .foregroundColor(adaptiveColor.opacity(0.7))

            Spacer().frame(height: 70)

            // Go back to Sign In
            ButtonView(title: "BACK TO SIGN IN", image: "arrow.right") {
                print("Back to sign in...")
            }

            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLottie = true
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
