//
//  AuthViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 24/02/2025.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import RevenueCat

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    // Published properties for tracking user session and related states
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var oobCode: String?
    @Published var isResetPassword: Bool = false
    @Published var isNewPassword: Bool = false

    
    init() {
        // Initialize current session if user is already logged in
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUserData()
        }
    }
    
// MARK: Sign In
    func signIn(withEmail email: String, password: String) async throws {
        do {
            // Attempt to sign in with Firebase
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            
            if result.user.isEmailVerified {
                // Check if User Data Exists in Firestore
                let snapshot = try await Firestore.firestore().collection("users").document(result.user.uid).getDocument()
                
                if snapshot.exists {
                    // Fetch User Data if it Exists
                    await fetchUserData()
                } else {
                    // Prompt User to Complete Registration
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name("CompleteRegistrationRequired"), object: nil)
                    }
                }
            } else {
                // If Email Not Verified, Sign Out and Show Alert
                try Auth.auth().signOut()
                self.userSession = nil
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name("EmailNotVerified"), object: nil)
                }
            }
        } catch {
            print("DEBUG: Failed to sign in with error: \(error.localizedDescription)")
            throw error
        }
    }

// MARK: Create new user
    func createUser(
        withEmail email: String,
        password: String,
        profileName: String = "",
        dob: Date = Date(),
        height: String = "",
        weight: String = "",
        gender: String = ""
    ) async throws {
        do {
            // Create a Temporary User
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let firebaseUser = result.user
            
            // Send Verification Email
            try await firebaseUser.sendEmailVerification()
            
            // Store User Data Temporarily
            UserDefaults.standard.setValue(firebaseUser.uid, forKey: "tempUID")
            UserDefaults.standard.setValue(email, forKey: "tempEmail")
            
            // Prompt User to Verify Email
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationSent"), object: nil)
            }
            
            // Sign Out the User if email not verified
            try Auth.auth().signOut()
            self.userSession = nil
            
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }
    
    
// MARK: Reset password
    func resetPassword(forEmail email: String) async throws {
        do {
            // send password reset email
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("DEBUG: Password reset email sent.")
        } catch {
            print("DEBUG: Failed to send password reset email: \(error.localizedDescription)")
            throw error
        }
    }

// MARK: Update password
    func updatePasswordInFirestore(newPassword: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            // Update password in Firestore
            try await Firestore.firestore().collection("users").document(uid).updateData([
                "password": newPassword
            ])
            
            print("DEBUG: Password updated successfully in Firestore.")
        } catch {
            print("DEBUG: Failed to update password in Firestore: \(error.localizedDescription)")
        }
    }

    
// MARK: Sign out
    func signOut() {
        do {
            // Sign out user clear local data
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            
            // Clear Temp Data
            UserDefaults.standard.removeObject(forKey: "tempEmail")
            UserDefaults.standard.removeObject(forKey: "tempProfileName")
            UserDefaults.standard.removeObject(forKey: "tempDOB")
            UserDefaults.standard.removeObject(forKey: "tempHeight")
            UserDefaults.standard.removeObject(forKey: "tempWeight")
            UserDefaults.standard.removeObject(forKey: "tempGender")
        } catch {
            print("DEBUG: Failed to sign out \(error.localizedDescription)")
        }
    }

// MARK: Delete account
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid

        let db = Firestore.firestore()

        do {
            // Delete from weeklyTopPerformers
            try await db
                .collection(DatabaseManager.shared.weeklyTopPerformers)
                .document(uid)
                .delete()
            print("Deleted from weeklyTopPerformers")

            // Delete from chartData
            try await db.collection("chartData").document(uid).delete()
            print("Deleted from chartData")

            // Delete from healthData
            try await db.collection("healthData").document(uid).delete()
            print("Deleted from healthData")

            // Delete all sub-documents in monthlyWorkouts/{uid}/history
            let historyCollection = db.collection("monthlyWorkouts").document(uid).collection("history")
            let historyDocs = try await historyCollection.getDocuments()
            for doc in historyDocs.documents {
                try await doc.reference.delete()
            }
            // Delete the parent document under monthlyWorkouts
            try await db.collection("monthlyWorkouts").document(uid).delete()
            print("Deleted from monthlyWorkouts")

            // Delete from users collection
            try await db.collection("users").document(uid).delete()
            print("Deleted user profile")

            // Delete FirebaseAuth user
            try await user.delete()
            print("Deleted FirebaseAuth user")

            // Clear local session
            self.userSession = nil
            self.currentUser = nil

        } catch {
            print("Error deleting account: \(error.localizedDescription)")
        }
    }

    
// MARK: Fetch user data
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // fetch user data from firestore using current user uid
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        do {
            let snapshot = try await userRef.getDocument()
            
            
            // Try automatic decoding first
            if let decodedUser = try? snapshot.data(as: User.self) {
                self.currentUser = User(
                    id: decodedUser.id,
                    email: decodedUser.email,
                    profileName: decodedUser.profileName,
                    dob: decodedUser.dob,
                    height: decodedUser.height,
                    weight: decodedUser.weight,
                    gender: decodedUser.gender,
                    password: "",  // Ensure password is never stored
                    profileAvatar: decodedUser.profileAvatar ?? (decodedUser.gender.lowercased() == "male" ? "man" : "woman")
                )
            } else {
                // Fallback to manual mapping if decoding fails
                if let data = snapshot.data() {
                    let gender = data["gender"] as? String ?? "female"
                    let avatar = data["profileAvatar"] as? String ?? (gender.lowercased() == "male" ? "man" : "woman")
                    
                    self.currentUser = User(
                        id: uid,
                        email: data["email"] as? String ?? "",
                        profileName: data["profileName"] as? String ?? "",
                        dob: data["dob"] as? String ?? "",
                        height: data["height"] as? String ?? "",
                        weight: data["weight"] as? String ?? "",
                        gender: data["gender"] as? String ?? "",
                        password: "",  // Always set an empty password
                        profileAvatar: avatar
                    )
                }
            }
            DispatchQueue.main.async {
                UserDefaults.standard.set(self.currentUser?.profileAvatar, forKey: "profileAvatar")
            }
        } catch {
            print("DEBUG: Failed to fetch user data: \(error.localizedDescription)")
        }
    }

    
// MARK: Update user name
    func updateUserName(newName: String) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(["profileName": newName])
            await fetchUserData() // Refresh user data after update
        } catch {
            print("DEBUG: Error updating username: \(error.localizedDescription)")
        }
    }
    
// MARK: Complete user registration
    func completeRegistration(
        profileName: String,
        dob: Date,
        height: String,
        weight: String,
        gender: String
    ) async throws {
        // Fetch temp email/uid from UserDefaults
        guard let uid = UserDefaults.standard.string(forKey: "tempUID"),
              let email = UserDefaults.standard.string(forKey: "tempEmail") else {
            print("DEBUG: User UID or Email not found in UserDefaults")
            return
        }
        
        // Format the Date of Birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let formattedDOB = dateFormatter.string(from: dob)
        
        // Create a user
        let user = User(
            id: uid,
            email: email,
            profileName: profileName,
            dob: formattedDOB,
            height: height,
            weight: weight,
            gender: gender,
            password: ""
        )
        
        do {
            // Encode and Store User Data in Firestore
            let encodeUser = try Firestore.Encoder().encode(user)
            
            try await Firestore.firestore().collection("users").document(uid).setData(encodeUser)
            
            // Clear Temp Data
            UserDefaults.standard.removeObject(forKey: "tempUID")
            UserDefaults.standard.removeObject(forKey: "tempEmail")
            
            // Fetch User Data to Confirm Completion
            await fetchUserData()
            
            print("DEBUG: User registration data saved successfully.")
            
        } catch {
            print("DEBUG: Error saving user data: \(error.localizedDescription)")
            throw error
        }
    }
    
// MARK: Update user's subscription status
    func updateSubscriptionStatusInFirestore(isActive: Bool) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Store subscription status in Firestore
        let userRef = Firestore.firestore().collection("users").document(uid)
        do {
            try await userRef.setData([
                "isPremiumUser": isActive,
                "subscriptionUpdatedAt": Timestamp(date: Date())
            ], merge: true)
            
            print("DEBUG: Subscription status updated in Firestore to \(isActive)")
        } catch {
            print("DEBUG: Failed to update subscription status: \(error.localizedDescription)")
        }
    }
    
// MARK: Refresh user's subscription status
    func refreshSubscriptionStatus() async {
        do {
            // Fetch subscription from RevenueCat
            let customerInfo = try await Purchases.shared.customerInfo()
            let isActive = customerInfo.entitlements["Subscription"]?.isActive == true

            // Update Firestore
            await updateSubscriptionStatusInFirestore(isActive: isActive)

            // Update local storage
            await MainActor.run {
                UserDefaults.standard.set(isActive, forKey: "isPremiumUser")
            }

            print("DEBUG: Subscription isActive: \(isActive)")
        } catch {
            print("DEBUG: Failed to refresh subscription status: \(error.localizedDescription)")
        }
    }
}


extension AuthViewModel {
    func updateUserDetails(name: String?, height: String?, weight: String?, profileAvatar: String?) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Update profile name, height, weight, and avatar in Firestore
        var updateData: [String: Any] = [:]
        
        if let name = name, !name.isEmpty {
            updateData["profileName"] = name
        }
        if let height = height, !height.isEmpty {
            updateData["height"] = height
        }
        if let weight = weight, !weight.isEmpty {
            updateData["weight"] = weight
        }
        if let avatar = profileAvatar {
            updateData["profileAvatar"] = avatar  
        }
        
        do {
            try await Firestore.firestore().collection("users").document(uid).updateData(updateData)
            print("DEBUG: User details updated successfully.")
            await fetchUserData()  // Refresh UI with updated data
        } catch {
            print("DEBUG: Failed to update user details: \(error.localizedDescription)")
        }
    }
}


