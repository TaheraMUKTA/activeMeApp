//
//  TopPerformersViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 12/03/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class TopPerformersViewModel: ObservableObject {
    
    @Published var performersResult = TopPerformersResult(user: nil, topten: [])
    
    var mockData = [
        TopPerformersUsers(id: "1", profilename: "Tahera", count: 7678),
        TopPerformersUsers(id: "2", profilename: "Mukta", count: 7478),
        TopPerformersUsers(id: "3", profilename: "Tamim", count: 7378),
        TopPerformersUsers(id: "4", profilename: "Foysal", count: 8278),
        TopPerformersUsers(id: "5", profilename: "Meera", count: 7178),
        TopPerformersUsers(id: "6", profilename: "Mohammad", count: 7078),
        TopPerformersUsers(id: "7", profilename: "Tasnim", count: 10878),
        TopPerformersUsers(id: "8", profilename: "Motaher", count: 6678),
        TopPerformersUsers(id: "9", profilename: "Hossain", count: 6378),
        TopPerformersUsers(id: "10", profilename: "Tanny", count: 6178)
    ]
    
    init() {
        Task {
            do {
                print("DEBUG: Fetching top performers data...")
                try await setTopPerformersData()
            } catch {
                print("DEBUG: Error fetching data \(error.localizedDescription)")
            }
        }
    }
    
    func setTopPerformersData() async throws {
        await DatabaseManager.shared.ensureWeeklyCollectionExists()
        try await postStepCountUpdateForUser()
        let result = try await fetchTopPerformers()
        DispatchQueue.main.async {
            self.performersResult = result
        }
    }
    
    
    struct TopPerformersResult {
        let user: TopPerformersUsers?
        let topten: [TopPerformersUsers]
    }
    
    private func fetchTopPerformers() async throws -> TopPerformersResult {
        let performers = try await DatabaseManager.shared.fetchTopPerformers()

        if performers.isEmpty {
            print("DEBUG: No performers found for this week. Ensure new week data is being created.")
        }

        var updatedPerformers = [TopPerformersUsers]()
        var currentUserPerformer: TopPerformersUsers? = nil

        for var performer in performers {
            let userRef = Firestore.firestore().collection("users").document(performer.id)
            let snapshot = try await userRef.getDocument()

            if let data = snapshot.data(), let nickname = data["profileName"] as? String {
                performer.profilename = nickname
            }

            updatedPerformers.append(performer)
            if performer.id == Auth.auth().currentUser?.uid {
                currentUserPerformer = performer
            }
            
        }

        let topten = Array(updatedPerformers.sorted(by: { $0.count > $1.count }).prefix(10))

        if let currentUser = currentUserPerformer, !topten.contains(where: { $0.id == currentUser.id }) {
                return TopPerformersResult(user: currentUser, topten: topten)
        } else {
            return TopPerformersResult(user: nil, topten: topten)
        }
    }
    
    
    func postStepCountUpdateForUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            print("DEBUG: No logged-in user")
            return
        }
        
        let userId = currentUser.uid
        let userRef = DatabaseManager.shared.database.collection("users").document(userId)
        let snapshot = try await userRef.getDocument()
        
        guard let userData = snapshot.data(), let profilename = userData["profileName"] as? String else { return }

        let steps = try await fetchCurrentWeekStepCount()

        let performer = TopPerformersUsers(id: userId, profilename: profilename, count: Int(steps))
        let weeklyTopPerformers = DatabaseManager.shared.weeklyTopPerformers
        let collectionRef = DatabaseManager.shared.database.collection(weeklyTopPerformers)

        let documentRef = collectionRef.document(userId)
        let performerSnapshot = try await documentRef.getDocument()

        if !performerSnapshot.exists {
            print("Creating a new entry for \(profilename)")
            let data = try Firestore.Encoder().encode(performer)
            try await documentRef.setData(data, merge: false)
        } else {
            print("Updating step count for \(profilename)")
            try await documentRef.updateData(["count": performer.count])
        }
    }


    
    private func fetchStepCountForUser(userId: String) async throws -> Double {
        // Fetch step count for the specific user from Firestore or HealthKit if they are logged in
        let userRef = DatabaseManager.shared.database.collection("users").document(userId)
        let snapshot = try await userRef.getDocument()
        
        if let userData = snapshot.data(), let steps = userData["steps"] as? Double {
            return steps
        } else {
            return 0.0 // Default to 0 if no steps recorded
        }
    }

    
    private func fetchCurrentWeekStepCount() async throws -> Double {
           try await withCheckedThrowingContinuation { continuation in
               HealthManager.shared.fetchCurrentWeekStepCount { result in
                   continuation.resume(with: result)
               }
           }
       }
    
}
