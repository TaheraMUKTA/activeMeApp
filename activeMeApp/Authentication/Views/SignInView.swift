//
//  SignInView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showLottie = false
    @State private var confirmPassword = ""
    @State private var errorMessage: String = ""
    @State private var showNotVerifiedAlert = false
    @State private var showCompleteRegistration = false


    @EnvironmentObject var viewModel: AuthViewModel

        var body: some View {
            NavigationStack {
                VStack {
                    
                    if showLottie {
                        LottieView(animationName: "dumbbell", width: 150, height: 150)
                            .frame(width: 200, height: 150)
                            .padding(.bottom, 30)
                            .padding(.top, 60)
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                            .keyboardType(.emailAddress)
                            .onChange(of: email) { _, newValue in
                                email = newValue.lowercased()
                            }
                                
                        
                        
                        InputView(text: $password, title: "Password", placeholder: "Enter your password",
                                  isSecureTextEntry: true)
                        
                        // Conditionally show Confirm Password only if it's a new password reset
                            if viewModel.isNewPassword {
                                InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm new password", isSecureTextEntry: true)
                                    .onChange(of: confirmPassword) { _, newValue in
                                        confirmPassword = newValue
                                    }
                            }
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.red)
                                    .padding(.top, 5)
                            }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 15)
                    
                    // Forgot Password Link
                    NavigationLink {
                        ForgotPasswordView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Forgot Password")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                    
                    // Sign In Button
                    // Sign In Button
                    ButtonView(title: "SIGN IN", image: "arrow.right") {
                        // Only check for password match if resetting password
                        if viewModel.isNewPassword {
                            guard password == confirmPassword else {
                                print("Passwords do not match.")
                                return
                            }
                        }
                        
                        Task {
                                do {
                                    try await viewModel.signIn(withEmail: email, password: password)
                                    errorMessage = "" // Clear error message on successful sign-in
                                } catch let error as NSError {
                                    if let authError = AuthErrorCode(rawValue: error.code) {
                                        switch authError {
                                        case .wrongPassword:
                                            errorMessage = "Incorrect password. Please try again."
                                        case .invalidEmail:
                                            errorMessage = "Invalid email format. Please check your email."
                                        case .userNotFound:
                                            errorMessage = "No account found with this email."
                                        case .networkError:
                                            errorMessage = "Network error. Please check your connection."
                                        case .userDisabled:
                                            errorMessage = "This account has been disabled."
                                        default:
                                            errorMessage = "Login failed. Please try again."
                                        }
                                    } else {
                                        errorMessage = "Login failed. Please try again."
                                    }
                                    print("Login failed: \(error.localizedDescription)")
                                }

                        }
                    }
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)

                    
                    Spacer()
                    
                    // Sign Up Link
                    NavigationLink {
                        SignUpView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3) {
                            Text("Don’t have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                            
                            Text("Sign Up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showLottie = true // Prevents immediate crash
                    }
                }
                .navigationDestination(isPresented: Binding(
                    get: { viewModel.userSession != nil },
                    set: { _ in }))
                {
                    FitnessTabView()
                }
                .onAppear {
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("EmailNotVerified"), object: nil, queue: .main) { _ in
                        showNotVerifiedAlert = true
                    }
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("CompleteRegistrationRequired"), object: nil, queue: .main) { _ in
                        showCompleteRegistration = true
                    }
                }
                .navigationDestination(isPresented: $showCompleteRegistration) {
                    CompleteRegistrationView(showCompleteRegistration: $showCompleteRegistration)
                        .environmentObject(viewModel)
                }
                .alert("Email Not Verified", isPresented: $showNotVerifiedAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Please verify your email before signing in. Check your inbox for the verification link.")
                }
            }
        }
}

//MARK: AuthenticationFormProtocol

extension SignInView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        // If a new password is being set, ensure passwords match
        if viewModel.isNewPassword {
            return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
            && confirmPassword == password
        } else {
            // Otherwise, validate as normal
            return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
        }
    }
}



#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
