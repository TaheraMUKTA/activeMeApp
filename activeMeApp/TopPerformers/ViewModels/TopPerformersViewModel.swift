//
//  TopPerformersViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 07/03/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth


class TopPerformersViewModel: ObservableObject {
    // Holds the result of the top performers query
    @Published var performersResult = TopPerformersResult(user: nil, topten: [])
    @Published var showAlert = false     // shows alerts when data fetching fails
    @Published var errorMessage: String = ""
    
    // mock data for testing
    var mockData = [
        TopPerformersUsers(id: "1", profilename: "Tahera", count: 7678),
        TopPerformersUsers(id: "2", profilename: "Mukta", count: 7478),
        TopPerformersUsers(id: "3", profilename: "Tamim", count: 7378),
        TopPerformersUsers(id: "4", profilename: "Fenil", count: 8278),
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
                try await setTopPerformersData()
            } catch {
                print("DEBUG: Error fetching data \(error.localizedDescription)")
            }
        }
    }
    
    // Forces a refresh of leaderboard data
    func refreshData() async {
        do {
            try await setTopPerformersData()
        } catch {
            DispatchQueue.main.async {
                self.showAlert = true
                self.errorMessage = "Failed to load data. Please try again."
            }
        }
    }
    
    // Fetches and updates the leaderboard with current and top user data
    func setTopPerformersData() async throws {
        await DatabaseManager.shared.ensureWeeklyCollectionExists()
        // Post or update the current user's step count
        do {
            try await postStepCountUpdateForUser()
        } catch {
            print("DEBUG: Failed to post user step count: \(error.localizedDescription)")
        }
        // Retrieve and display top performers
        let result = try await fetchTopPerformers()
        DispatchQueue.main.async {
            self.performersResult = result
        }
    }
    
    // holds the top 10 current and current user
    struct TopPerformersResult {
        let user: TopPerformersUsers?
        let topten: [TopPerformersUsers]
    }
    
    // Retrieves weekly top performers from Firestore and updates usernames from users collection
    private func fetchTopPerformers() async throws -> TopPerformersResult {
        await DatabaseManager.shared.ensureWeeklyCollectionExists()
        do {
            let performers = try await DatabaseManager.shared.database.collection(DatabaseManager.shared.weeklyTopPerformers).getDocuments()
                .documents.compactMap { try? $0.data(as: TopPerformersUsers.self) }
            if performers.isEmpty {
                print("DEBUG: No performers found for this week.")
            }

            var updatedPerformers = [TopPerformersUsers]()
            var currentUserPerformer: TopPerformersUsers? = nil

            for var performer in performers {
                // Update profile name from `users` collection
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

            // Sort and trim to top 10
            let topten = Array(updatedPerformers.sorted(by: { $0.count > $1.count }).prefix(10))
            
            // Return data with current user if not in top 10
            if let currentUser = currentUserPerformer, !topten.contains(where: { $0.id == currentUser.id }) {
                return TopPerformersResult(user: currentUser, topten: topten)
                
            } else {
                return TopPerformersResult(user: nil, topten: topten)
            }
        } catch let error as NSError {
            print("DEBUG: Firestore fetch error: \(error), \(error.localizedDescription)")
            throw error
        }
    }
    
    // Uploads or updates the current user's step count for this week in Firestore
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
            // Create new document if doesn't exist
            let data = try Firestore.Encoder().encode(performer)
            try await documentRef.setData(data, merge: false)
        } else {
            // Update step count
            try await documentRef.updateData(["count": performer.count])
        }
    }
    
    // Fetch step count from user's Firestore document
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

    // Wrapper to call `HealthManager` and fetch the user's step count for the current week
    private func fetchCurrentWeekStepCount() async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            HealthManager.shared.fetchCurrentWeekStepCount { result in
                continuation.resume(with: result)
            }
        }
    }
}
