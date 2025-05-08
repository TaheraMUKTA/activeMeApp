//
//  DatabaseManager.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 05/03/2025.
//

import Foundation
import FirebaseFirestore

// This class manages all Firestore database operations
class DatabaseManager {
    
    // shared instance used throughout the app
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    // Generates a collection name like "2025-04-21-topPerformers" based on current week Monday's date
    let weeklyTopPerformers = "\(Date().mondayDateFormat())-topPerformers"
    
    // To fetch top performers from the Firestore collection
    func fetchTopPerformers() async throws -> [TopPerformersUsers]{
        let snapshot = try await database.collection(weeklyTopPerformers).getDocuments()
        // Convert each document into a TopPerformersUsers object
        return try snapshot.documents.compactMap({ try $0.data(as: TopPerformersUsers.self) })
    }
    
    // To add or update step count for a user
    func postStepCountUpdateForUser(performer: TopPerformersUsers) async throws {
        let collectionRef = database.collection(weeklyTopPerformers)
        let documentRef = collectionRef.document(performer.id)

        // Check if the user document already exists
        let snapshot = try await documentRef.getDocument()
        
        if !snapshot.exists {
            // If not, create a new document with user's data
            print("Creating a new entry for \(performer.profilename)")
            let data = try Firestore.Encoder().encode(performer)
            try await documentRef.setData(data, merge: false)
        } else {
            // If found, just update the step count
            print("Updating step count for existing user \(performer.profilename)")
            try await documentRef.updateData(["count": performer.count])
        }
    }

    // Function to create the weekly top performers collection if it doesn't exist
    func ensureWeeklyCollectionExists() async {
        let collectionRef = database.collection(weeklyTopPerformers)
        let snapshot = try? await collectionRef.getDocuments()
        
        // If the collection is empty, create it
        if snapshot?.documents.isEmpty ?? true {
            print("DEBUG: No data found for \(weeklyTopPerformers), creating new weekly collection.")

            // Fetch all users from the main "users" collection
            let usersSnapshot = try? await database.collection("users").getDocuments()
            let users = usersSnapshot?.documents.compactMap { document -> TopPerformersUsers? in
                if let id = document.documentID as String?,
                   let profilename = document.data()["profileName"] as? String {
                    // Create a new user entry with step count 0
                    return TopPerformersUsers(id: id, profilename: profilename, count: 0)
                }
                return nil
            } ?? []

            // Batch write all users to avoid multiple calls
            let batch = database.batch()
            for user in users {
                let userRef = collectionRef.document(user.id)
                let data = try? Firestore.Encoder().encode(user)
                batch.setData(data ?? [:], forDocument: userRef, merge: false)
            }
            // Commit all batch writes to Firestore
            try? await batch.commit()
        }
    }
}
