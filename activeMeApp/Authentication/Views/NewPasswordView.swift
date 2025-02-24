//
//  NewPasswordView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct NewPasswordView: View {
    @State private var showLottie = false
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) var dismiss
    
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

                   Text("New Password")
                       .font(.title)
                       .bold()
                       .padding(.bottom, 20)
                       

                   Spacer().frame(height: 50)

                   VStack(alignment: .leading, spacing: 12) {
                       InputView(text: $password, title: "Password", placeholder: "Enter your new password", isSecureTextEntry: true)
                       
                       InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your new password", isSecureTextEntry: true)

                   }
                   .padding(.horizontal, 30)


                   Spacer().frame(height: 20)

                    ButtonView(title: "RESET PASSWORD", image: "arrow.right") {
                        print("Resetting password...")
                    }

                   Spacer()

                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 3) {
                            Text("Already have an account?")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                    
                            Text("Sign In")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        }
                    }

               }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showLottie = true
                    }
                }
    }
}

#Preview {
    NewPasswordView()
}
