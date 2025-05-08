//
//  SignUpView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var showLottie = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showVerificationAlert = false
    @State private var showCompleteRegistration = false
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        // Adaptive color for dark/light mode
        let adaptiveColor = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        NavigationStack {
            VStack {
                Spacer().frame(height: 70)
                
                if showLottie {
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 170, height: 120)
                        .padding(.bottom, -20)
                        .padding(.top, -40)
                    
                }
                Spacer().frame(height: 30)
                
                VStack {
                    Spacer().frame(height: 30)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Email
                        InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                            .keyboardType(.emailAddress)
                            .onChange(of: email) { _, newValue in
                                email = newValue.lowercased()
                            }
                        
                        // Password
                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureTextEntry: true)
                        
                        // Confirm Password
                        ZStack(alignment: .trailing) {
                            InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureTextEntry: true)
                            // Show check or X mark based on match
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                if password == confirmPassword {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color.green)
                                        .padding(.leading, 5)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(.systemRed))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer().frame(height: 15)
                    
                    // Sign Up Button
                    ButtonView(title: "SIGN UP", image: "arrow.right") {
                        Task {
                            do {
                                // Create User with Email and Password
                                try await viewModel.createUser(
                                    withEmail: email,
                                    password: password
                                    
                                )
                                
                                // Clear all fields after successful sign up
                                email = ""
                                password = ""
                                confirmPassword = ""
                                
                                // Navigate to CompleteRegistrationView
                                showCompleteRegistration = true
                            } catch {
                                print("Sign Up failed: \(error.localizedDescription)")
                            }
                        }
                    }
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)
                    
                    Spacer().frame(height: 200)
                    
                    // Navigate to Sign In
                    NavigationLink {
                        SignInView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Already have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(adaptiveColor)
                            
                            Text("Sign In")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLottie = true // Prevents immediate crash
                }
            }
            // Listen for email verification alert
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("EmailVerificationSent"), object: nil, queue: .main) { _ in
                    showVerificationAlert = true
                }
            }
            // Alert shown after email verification is sent
            .alert("Verification Email Sent", isPresented: $showVerificationAlert) {
                Button("OK", role: .cancel) {
                    // Redirect to Sign In Page
                    dismiss()
                }
            } message: {
                Text("Please check your email to verify your account before signing in.")
            }
            // Navigate to registration form after signup
            .navigationDestination(isPresented: $showCompleteRegistration) {
                CompleteRegistrationView(showCompleteRegistration: $showCompleteRegistration)
                    .environmentObject(viewModel)
            }
        }
    }
}

// MARK: Form Validation

extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && email.contains(".")
        && !password.isEmpty
        && password.count > 5
        && !confirmPassword.isEmpty
        && confirmPassword == password
    }
}


#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}

    
