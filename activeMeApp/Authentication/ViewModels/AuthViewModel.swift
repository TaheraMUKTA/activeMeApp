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
            
            // Check if this is a first login after a password reset
            if let isNewPassword = UserDefaults.standard.value(forKey: "isNewPassword") as? Bool, isNewPassword {
                UserDefaults.standard.setValue(false, forKey: "isNewPassword")
                self.isNewPassword = true  // Show Confirm Password field
                
                // Prompt user to update password in Firestore
                await updatePasswordInFirestore(newPassword: password)
            } else {
                self.isNewPassword = false  // Hide Confirm Password field
            }
            
            await fetchUserData()
        } catch {
            print("DEBUG: Failed to sign in with error: \(error.localizedDescription)")
        }
    }



    
    func createUser(withEmail email: String, password: String, profileName: String, dob: Date, height: String, weight: String, gender: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, email: email, profileName: profileName, dob: Date(), height: height, weight: weight, gender: gender, password: password)
            let encodeUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodeUser)
            await fetchUserData()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
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
    
}


