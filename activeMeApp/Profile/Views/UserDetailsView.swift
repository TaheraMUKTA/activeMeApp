//
//  UserDetailsView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 11/03/2025.
//

import SwiftUI

// Displays and allows editing of the authenticated user's personal details.
struct UserDetailsView: View {
    @StateObject var profileViewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Edit state toggles for each field
    @State private var isEditingName = false
    @State private var isEditingHeight = false
    @State private var isEditingWeight = false

    // Local input values for updated user data
    @State private var newName: String = ""
    @State private var newHeight: String = ""
    @State private var newWeight: String = ""

    
    let user: User

    var body: some View {
        
        VStack(spacing: 15) {
            // Header
            Text("User Details")
                .font(.title)
                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                .fontWeight(.bold)
                .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 10) {
                                    
                    // MARK: - Name Editing Section
                    if isEditingName {
                        TextField("New User Name...", text: $newName)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2))

                        HStack(spacing: 25) {
                            // Cancel name edit
                            ProfileEditButtonView(title: "Cancel", backgroundColor: .blue) {
                                withAnimation {
                                    isEditingName = false
                                    newName = user.profileName
                                    }
                                }
                                // Save name update
                                ProfileEditButtonView(title: "Save", backgroundColor: .green) {
                                    Task {
                                        await authViewModel.updateUserDetails(name: newName, height: nil, weight: nil, profileAvatar: nil)
                                        await authViewModel.fetchUserData()
                                        isEditingName = false
                                    }
                                }
                            }
                        } else {
                            // Read-only name row
                            DetailsRowView(title: "Name", value: user.profileName) {
                                withAnimation {
                                    isEditingName = true
                                    isEditingHeight = false
                                    isEditingWeight = false
                                    newName = user.profileName
                                }
                            }
                        }

                        // MARK: - Height Editing Section
                        if isEditingHeight {
                            TextField("New Height...", text: $newHeight)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2))

                            HStack(spacing: 25) {
                                ProfileEditButtonView(title: "Cancel", backgroundColor: .blue) {
                                    withAnimation {
                                    isEditingHeight = false
                                    newHeight = user.height
                                    }
                                }
                                ProfileEditButtonView(title: "Save", backgroundColor: .green) {
                                    Task {
                                        await authViewModel.updateUserDetails(name: nil, height: newHeight, weight: nil, profileAvatar: nil)
                                        await authViewModel.fetchUserData()
                                        profileViewModel.recalculateBMI(height: newHeight, weight: user.weight)
                                        isEditingHeight = false
                                    }
                                }
                            }
                        } else {
                            DetailsRowView(title: "Height", value: "\(user.height) cm") {
                                withAnimation {
                                    isEditingHeight = true
                                    isEditingName = false
                                    isEditingWeight = false
                                    newHeight = user.height
                                }
                            }
                        }

                        // MARK: - Weight Editing Section
                        if isEditingWeight {
                            TextField("New Weight...", text: $newWeight)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2))

                            HStack(spacing: 25) {
                                ProfileEditButtonView(title: "Cancel", backgroundColor: .blue) {
                                    withAnimation {
                                        isEditingWeight = false
                                        newWeight = user.weight
                                    }
                                }
                                ProfileEditButtonView(title: "Save", backgroundColor: .green) {
                                    Task {
                                        await authViewModel.updateUserDetails(name: nil, height: nil, weight: newWeight, profileAvatar: nil)
                                        await authViewModel.fetchUserData()
                                            profileViewModel.recalculateBMI(height: user.height, weight: newWeight)
                                        isEditingWeight = false
                                    }
                                }
                            }
                        } else {
                            DetailsRowView(title: "Weight", value: "\(user.weight) kg") {
                                withAnimation {
                                    isEditingWeight = true
                                    isEditingName = false
                                    isEditingHeight = false
                                    newWeight = user.weight
                                }
                            }
                        }

                        // MARK: - Other Profile Details (Non-editable)
                        DetailsRowView(title: "Email", value: user.email)
                        DetailsRowView(title: "Date of Birth", value: user.dob)
                        DetailsRowView(title: "Gender", value: user.gender)

                        // MARK: - BMI Display
                        if let bmiValue = profileViewModel.bmi {
                            DetailsRowView(title: "BMI", value: String(format: "%.1f", bmiValue))
                                .foregroundColor(.blue)
                            DetailsRowView(title: "Category", value: profileViewModel.bmiCategory)
                                .foregroundColor(profileViewModel.bmiCategory == "Normal" ? .green : .red)
                        } else {
                            DetailsRowView(title: "BMI", value: "N/A")
                            DetailsRowView(title: "Category", value: "N/A")
                        }
                }
                .padding()
            }
            Spacer()
        }
        // Initialize BMI when view appears
        .onAppear {
            profileViewModel.setUser(user)
        }
    }
}

#Preview {
    UserDetailsView(user: User(id: "1", email: "test@example.com", profileName: "John Doe", dob: "12 Jan 2000", height: "175", weight: "70", gender: "Male", password: "" ))
}
