//
//  ForgotPasswordView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var showLottie = false
    
    var body: some View {
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

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email Address")
                            .font(.headline)
                            .bold()

                        TextField("name-example.com", text: .constant(""))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.vertical, 10)
                            .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)

                    Spacer().frame(height: 30)

                    Button(action: {}) {
                        HStack {
                            Text("CONTINUE")
                                .font(.headline)
                                .bold()
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    HStack {
                        Text("Remember your password?")
                        Text("Sign In")
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            .bold()
                    }
                    .font(.system(size: 14))

                    Spacer().frame(height: 20)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showLottie = true
                    }
                }
    }
}

#Preview {
    ForgotPasswordView()
}
