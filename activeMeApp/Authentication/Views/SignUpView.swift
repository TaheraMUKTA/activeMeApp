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
    @State private var profileName = ""
    @State private var selectedDate = Date()
    @State private var dobPlaceholder = "Enter your Date of Birth"
    @State private var height = ""
    @State private var weight = ""
    @State private var genderPlaceholder = "Enter your Gender"
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isDatePickerVisible = false
    @State private var isGenderPickerVisible = false
    @State private var isChecked = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    let genders = ["Male", "Female", "Other"]
    
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

                    VStack(alignment: .leading, spacing: 12) {
                        InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                            .keyboardType(.emailAddress)
                            .onChange(of: email) { _, newValue in
                                email = newValue.lowercased()
                            }
                        InputView(text: $profileName, title: "Full Name", placeholder: "Enter your full name")
                            .autocapitalization(.words)
                            .onChange(of: profileName) { _, newValue in
                                profileName = newValue.capitalized
                            }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("DOB")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(.darkGray))
                                        
                            HStack {
                                TextField(dobPlaceholder, text: .constant(""))
                                    .disabled(true)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray.opacity(0.5))

                                Image(systemName: "calendar")
                                    .foregroundColor(.green)
                                    .onTapGesture {
                                        isDatePickerVisible.toggle()
                                    }
                                }
                            
                                Divider()
                            }
                            .padding(.bottom, 10)
                            .sheet(isPresented: $isDatePickerVisible) {
                            
                        VStack {
                            DatePicker("Select your Date of Birth", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                                .onChange(of: selectedDate) { _, newValue in
                                    dobPlaceholder = DateFormatterHelper.shared.formatDate(newValue)
                                        isDatePickerVisible = false
                                    }
                            }
                        }
                        
                        InputView(text: $height, title: "Height (cm)", placeholder: "Enter your Height in cm")
                            .keyboardType(.numberPad)
                            .onChange(of: height) { _, newValue in
                                height = newValue.filter { "0123456789".contains($0) }
                            }
                        
                        InputView(text: $weight, title: "Weight (kg)", placeholder: "Enter your Weight in kg")
                            .keyboardType(.numberPad)
                            .onChange(of: weight) { _, newValue in
                                weight = newValue.filter { "0123456789".contains($0) }
                            }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Gender")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(.darkGray))

                            HStack {
                                TextField(genderPlaceholder, text: .constant(""))
                                    .disabled(true)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray.opacity(0.5))

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        isGenderPickerVisible.toggle()
                                    }
                            }
                            
                            Divider()
                        }
                        .padding(.bottom, 10)
                        .actionSheet(isPresented: $isGenderPickerVisible) {
                            ActionSheet(
                                title: Text("Select Gender"),
                                buttons: genders.map { gender in
                                    .default(Text(gender)) {
                                        genderPlaceholder = gender
                                }
                                } + [.cancel()]
                            )
                        }
                        
                        InputView(text: $password, title: "Password", placeholder: "Enter your password", isSecureTextEntry: true)
                        
                        ZStack(alignment: .trailing) {
                            InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureTextEntry: true)
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                if password == confirmPassword {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle((Color(red: 15/255, green: 174/255, blue: 1/255))).padding(.leading, 5)
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundStyle(Color(.systemRed))
                                }
                            }
                        }
                        
                        HStack {
                            Button(action: {
                                isChecked.toggle()
                            }) {
                                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                                    .foregroundColor(isChecked ? Color(red: 15/255, green: 174/255, blue: 1/255) : .gray)
                            }

                            Text("By checking this box you agree with the terms and conditions of using activeMe app.")
                                .font(.system(size: 14))
                                                
                        }
                    }
                    .padding(.horizontal, 30)

                    Spacer().frame(height: 15)

                ButtonView(title: "SIGN UP", image: "arrow.right") {
                    Task {
                        try await viewModel.createUser(withEmail: email, password: password, profileName: profileName, dob: selectedDate, height: height, weight: weight, gender: genderPlaceholder)
                        
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)

                Spacer().frame(height: 30)

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
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLottie = true
            }
        }
    }
}

//MARK: AuthenticationFormProtocol

extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && !confirmPassword.isEmpty
        && confirmPassword == password
        && !profileName.isEmpty
        && !dobPlaceholder.isEmpty
        && !genderPlaceholder.isEmpty
        && !height.isEmpty
        && !weight.isEmpty
        && isChecked
    
    }
}


#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
