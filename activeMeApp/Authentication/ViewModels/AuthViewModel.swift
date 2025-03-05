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

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var oobCode: String?
    @Published var isResetPassword: Bool = false
    @Published var isNewPassword: Bool = false

    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUserData()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
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
            // Step 1: Create a Temporary User
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let firebaseUser = result.user
            
            // Step 2: Send Verification Email
            try await firebaseUser.sendEmailVerification()
            
            // Step 3: Store User Data Temporarily
            UserDefaults.standard.setValue(firebaseUser.uid, forKey: "tempUID")
            UserDefaults.standard.setValue(email, forKey: "tempEmail")
            
            // Step 4: Prompt User to Verify Email
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("EmailVerificationSent"), object: nil)
            }
            
            // Step 5: Sign Out the User
            try Auth.auth().signOut()
            self.userSession = nil
            
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
            throw error
        }
    }







    
    
    
    func resetPassword(forEmail email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("DEBUG: Password reset email sent.")
        } catch {
            print("DEBUG: Failed to send password reset email: \(error.localizedDescription)")
            throw error
        }
    }

    
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

    
    
    func signOut() {
        do {
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

    
   func deleteAccount() async {
       guard let user = Auth.auth().currentUser else { return }
       guard let uid = user.uid as String? else { return }
       
       do {
           // Delete user data from Firestore
           try await Firestore.firestore().collection("users").document(uid).delete()
           
           // Delete user from Firebase Authentication
           try await user.delete()
           
           // Clear local session data
           self.userSession = nil
           self.currentUser = nil
           
           print("DEBUG: Account successfully deleted.")
       } catch {
           print("DEBUG: Error deleting account: \(error.localizedDescription)")
       }
    }
    
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
    }
    
    
    func updateUserName(newName: String) async {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            do {
                try await Firestore.firestore().collection("users").document(uid).updateData(["profileName": newName])
                await fetchUserData() // Refresh user data after update
            } catch {
                print("DEBUG: Error updating username: \(error.localizedDescription)")
            }
        }
    
    
    func completeRegistration(
        profileName: String,
        dob: Date,
        height: String,
        weight: String,
        gender: String
    ) async throws {
        // Retrieve the stored uid and email
        guard let uid = UserDefaults.standard.string(forKey: "tempUID"),
              let email = UserDefaults.standard.string(forKey: "tempEmail") else {
            print("DEBUG: User UID or Email not found in UserDefaults")
            return
        }
        
        // Format the Date of Birth
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy"
        let formattedDOB = dateFormatter.string(from: dob)
        
        // Create a User Object
        let user = User(
            id: uid,
            email: email,
            profileName: profileName,
            dob: formattedDOB,
            height: height,
            weight: weight,
            gender: gender,
            password: ""  // Don't store the password here
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

    
    

    
}


