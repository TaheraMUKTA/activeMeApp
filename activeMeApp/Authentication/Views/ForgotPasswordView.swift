//
//  ForgotPasswordView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var showLottie = false
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        // Adaptive color for dark/light mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        NavigationStack {
            
            VStack {
                Spacer().frame(height: 30)
                
                if showLottie {
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 170, height: 120)
                        .padding(.bottom, -20)
                        .padding(.top, 20)
                }
                
                Spacer().frame(height: 30)
                
                Text("Forgot Password?")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 10)
                
                Text("Enter your Email Address")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                    .padding(.bottom, 30)
                
                Spacer().frame(height: 30)
                
                // Email input field
                VStack(alignment: .leading, spacing: 10) {
                    InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                        .keyboardType(.emailAddress)
                        .onChange(of: email) { _, newValue in
                            email = newValue.lowercased()        // Always store lowercase email
                        }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
                
                // Continue button to send reset email
                ButtonView(title: "CONTINUE", image: "arrow.right") {
                    // Check if email field is valid
                    guard !email.isEmpty else {
                        alertMessage = "Please enter your email address."
                        showAlert = true
                        return
                    }
                    
                    guard email.contains("@") && email.contains(".") else {
                        alertMessage = "Please enter a valid email address."
                        showAlert = true
                        return
                    }
                    
                    // Call reset function from ViewModel
                    Task {
                        do {
                            try await viewModel.resetPassword(forEmail: email)
                            alertMessage = "A password reset email has been sent to \(email). Please check your inbox."
                            showAlert = true
                            UserDefaults.standard.setValue(true, forKey: "isNewPassword")
                        } catch {
                            alertMessage = "Failed to send password reset email. Please try again."
                            showAlert = true
                        }
                    }
                    
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)

                
                Spacer()
                
                // Go back to Sign In
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Text("Remmber your password?")
                            .font(.system(size: 14))
                            .foregroundColor(adaptiveColor)
                        
                        Text("Sign In")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                    }
                }
                .font(.system(size: 14))
                
                Spacer().frame(height: 20)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLottie = true
                }
            }
            // Show alert for success or error messages
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

// form validation
extension ForgotPasswordView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.contains(".")
        
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
}
