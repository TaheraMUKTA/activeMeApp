//
//  DatabaseManager.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import Foundation
import FirebaseFirestore

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private init() {}
    
    let database = Firestore.firestore()
    let weeklyTopPerformers = "\(Date().mondayDateFormat())-topPerformers"
    
    func fetchTopPerformers() async throws -> [TopPerformersUsers]{
        let snapshot = try await database.collection(weeklyTopPerformers).getDocuments()
        
        return try snapshot.documents.compactMap({ try $0.data(as: TopPerformersUsers.self) })
        
    }
    
    func postStepCountUpdateForUser(performer: TopPerformersUsers) async throws {
            let collectionRef = database.collection(weeklyTopPerformers)
            let documentRef = collectionRef.document(performer.id)

            let snapshot = try await documentRef.getDocument()
            
            if !snapshot.exists {
                print("Creating a new entry for \(performer.profilename)")
                let data = try Firestore.Encoder().encode(performer)
                try await documentRef.setData(data, merge: false)
            } else {
                print("Updating step count for existing user \(performer.profilename)")
                try await documentRef.updateData(["count": performer.count])
            }
        }

    func ensureWeeklyCollectionExists() async {
            let collectionRef = database.collection(weeklyTopPerformers)
            let snapshot = try? await collectionRef.getDocuments()
            
            if snapshot?.documents.isEmpty ?? true {
                print("DEBUG: No data found for \(weeklyTopPerformers), adding users to weekly collection.")

                let usersSnapshot = try? await database.collection("users").getDocuments()
                let users = usersSnapshot?.documents.compactMap { document -> TopPerformersUsers? in
                    if let id = document.documentID as String?,
                       let profilename = document.data()["profileName"] as? String {
                        return TopPerformersUsers(id: id, profilename: profilename, count: 0)
                    }
                    return nil
                }

                for user in users ?? [] {
                    let data = try? Firestore.Encoder().encode(user)
                    try? await collectionRef.document(user.id).setData(data ?? [:], merge: false)
                }
            }
        }
    
}
