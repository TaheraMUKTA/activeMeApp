//
//  CompleteRegistationView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/02/2025.
//

import SwiftUI

struct CompleteRegistrationView: View {
    @Binding var showCompleteRegistration: Bool  // Use @Binding for navigation state

    @State private var showLottie = false
    @State private var profileName = ""
    @State private var selectedDate = Date()
    @State private var dobPlaceholder = "Enter your Date of Birth"
    @State private var height = ""
    @State private var weight = ""
    @State private var genderPlaceholder = "Enter your Gender"
    @State private var isDatePickerVisible = false
    @State private var isGenderPickerVisible = false
    @State private var isChecked = false
    @State private var showSuccessAlert = false

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
                    // Full Name
                    InputView(text: $profileName, title: "Full Name", placeholder: "Enter your full name")
                        .autocapitalization(.words)
                        .onChange(of: profileName) { _, newValue in
                            profileName = newValue.capitalized
                        }
                    
                    // Date of Birth
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
                    
                    // Height
                    InputView(text: $height, title: "Height (cm)", placeholder: "Enter your Height in cm")
                        .keyboardType(.numberPad)
                        .onChange(of: height) { _, newValue in
                            height = newValue.filter { "0123456789".contains($0) }
                        }
                    
                    // Weight
                    InputView(text: $weight, title: "Weight (kg)", placeholder: "Enter your Weight in kg")
                        .keyboardType(.numberPad)
                        .onChange(of: weight) { _, newValue in
                            weight = newValue.filter { "0123456789".contains($0) }
                        }
                    
                    // Gender
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
                    
                    // Checkbox for Agreement
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

                // Complete Registration Button
                ButtonView(title: "Complete Registration", image: "arrow.right") {
                    Task {
                        do {
                            try await viewModel.completeRegistration(
                                profileName: profileName,
                                dob: selectedDate,
                                height: height,
                                weight: weight,
                                gender: genderPlaceholder
                            )
                            
                            print("DEBUG: Registration completed successfully.")
                                       
                                       // Show success alert and navigate back to SignInView
                                       await MainActor.run {
                                           showSuccessAlert = true
                                       }
                        } catch {
                            print("Complete Registration failed: \(error.localizedDescription)")
                        }
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)
                .alert("Registration Completed", isPresented: $showSuccessAlert) {
                    Button("OK") {
                        dismiss() // Navigate back to SignInView
                    }
                } message: {
                    Text("Your account has been successfully created. You can now sign in.")
                }

                Spacer().frame(height: 30)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLottie = true
            }
        }
    }
}

// MARK: - Form Validation
extension CompleteRegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return isChecked
        && !profileName.isEmpty
        && !dobPlaceholder.isEmpty
        && !genderPlaceholder.isEmpty
        && !height.isEmpty
        && !weight.isEmpty
    }
}
