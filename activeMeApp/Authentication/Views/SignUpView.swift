//
//  SignUpView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct SignUpView: View {
    @State private var showLottie = false
    
    var body: some View {
        ScrollView {
            VStack {
                        Spacer().frame(height: 30)

                        if showLottie {
                            LottieView(animationName: "dumbbell", width: 150, height: 150)
                                .frame(width: 170, height: 120)
                                .padding(.bottom, -20)
                                .padding(.top, -40)

                        }
                        Spacer().frame(height: 30)

                        VStack(alignment: .leading, spacing: 35) {
                            InputField(title: "Email Address", placeholder: "name@example.com")
                            InputField(title: "Full Name", placeholder: "Enter your name")
                            InputField(title: "DOB", placeholder: "Enter your Date of Birth", isDatePicker: true)
                            InputField(title: "Height", placeholder: "Enter your Height", isDropdown: true)
                            InputField(title: "Weight", placeholder: "Enter your Weight")
                            InputField(title: "Gender", placeholder: "Enter your Gender", isDropdown: true)
                            InputField(title: "Password", placeholder: "Enter your password", isSecure: true)
                            InputField(title: "Confirm Password", placeholder: "Confirm your password", isSecure: true)

                            HStack {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                Text("By checking this box you agree with the terms and conditions of using activeMe app.")
                                    .font(.system(size: 14))
                            }
                            .padding(.vertical, 10)
                        }
                        .padding(.horizontal, 30)

                        Spacer().frame(height: 20)

                        Button(action: {}) {
                            HStack {
                                Text("SIGN UP")
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

                        Spacer().frame(height: 20)

                        HStack {
                            Text("Already have an account?")
                            Text("Sign In")
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                .bold()
                        }
                        .font(.system(size: 14))

                        Spacer().frame(height: 20)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showLottie = true 
                    }
                }
    }
}


struct InputField: View {
    let title: String
    let placeholder: String
    var isSecure: Bool = false
    var isDatePicker: Bool = false
    var isDropdown: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .bold()

            if isSecure {
                SecureField(placeholder, text: .constant(""))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            } else if isDatePicker {
                HStack {
                    TextField(placeholder, text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)

                    Image(systemName: "calendar")
                        .foregroundColor(.green)
                }
                .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            } else if isDropdown {
                HStack {
                    TextField(placeholder, text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 10)

                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            } else {
                TextField(placeholder, text: .constant(""))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 1).foregroundColor(.gray), alignment: .bottom)
            }
        }
    }
}


#Preview {
    SignUpView()
}
