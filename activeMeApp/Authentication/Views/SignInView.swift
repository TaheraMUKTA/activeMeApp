//
//  SignInView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct SignInView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showLottie = false

        var body: some View {
            VStack {
                
                if showLottie {
                    LottieView(animationName: "dumbbell", width: 150, height: 150)
                        .frame(width: 200, height: 150)
                        .padding(.bottom, 30)
                        .padding(.top, 60)
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    TextField("name-example.com", text: $email)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal, 40)

                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    SecureField("Enter your password", text: $password)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.5))
                }
                .padding(.horizontal, 40)
                .padding(.top, 15)

                // Forgot Password Link
                HStack {
                    Spacer()
                    Text("Forgot Password")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)

                // Sign In Button
                Button(action: {}) {
                    HStack {
                        Text("SIGN IN")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)

                Spacer()

                // Sign Up Link
                HStack {
                    Text("Don’t have an account?")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    
                    Text("Sign Up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showLottie = true // Prevents immediate crash
                }
            }
        }
}

#Preview {
    SignInView()
}
