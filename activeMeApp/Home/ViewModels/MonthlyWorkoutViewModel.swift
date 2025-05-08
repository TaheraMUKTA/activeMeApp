//
//  MonthlyWorkoutViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 17/03/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class MonthlyWorkoutViewModel: ObservableObject {
    @Published var selectedMonth = 0
    @Published var selectedDate = Date()
    var fetchedMonths: Set<String> = []
    
    @Published var workouts = [Workout]()
    @Published var currentMonthlyWorkout = [Workout]()    // Filtered list for selected month
    
    @Published var showAlert = false
    
    init() {
        
        // On initialization, fetch current month's workouts
        Task {
            do {
                try await fetchWorkoutsForMonth()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert = true
                }
            }
        }
    }
    
    // Updates selectedDate based on selectedMonth offset and fetches corresponding data.
    func updateSelectedDate() {
        self.selectedDate = Calendar.current.date(byAdding: .month, value: selectedMonth, to: Date()) ?? Date()
        let monthKey = selectedDate.monthAndYearFormat()

        Task {
            do {
                if selectedDate.isCurrentMonth() {
                    // Fetch from HealthKit and store it in Firestore for the current month
                    try await fetchWorkoutsForMonth()
                } else {
                    // Fetch from HealthKit for past months instead of Firestore
                    try await fetchPastMonthWorkouts()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.showAlert = true
                }
            }
        }
    }


    // Fetches current month's workouts from HealthKit and stores them in Firestore
    func fetchWorkoutsForMonth() async throws {
        let monthKey = selectedDate.monthAndYearFormat()

        guard selectedDate.isCurrentMonth() else {
            print("Skipping HealthKit fetch: \(monthKey) is not the current month.")
            return
        }

        try await withCheckedThrowingContinuation({ continuation in
            HealthManager.shared.fetchWorkoutsForMonth(month: selectedDate) { result in
                switch result {
                case .success(let workouts):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        // Remove old data for the current month
                        self.workouts.removeAll { $0.date.monthAndYearFormat() == monthKey }

                        // Add new workouts
                        self.workouts.append(contentsOf: workouts)
                        self.currentMonthlyWorkout = self.workouts.filter { $0.date.monthAndYearFormat() == monthKey }

                        // Store in Firestore (Only for the current month)
                        Task {
                            await self.saveMonthlyWorkoutsToFirestore()
                        }

                        continuation.resume()
                    }

                case .failure(_):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.showAlert = true
                        continuation.resume()
                    }
                }
            }
        }) as Void
    }


    // Saves current month's workout data to Firestore under `/monthlyWorkouts/history/{monthKey}`
    func saveMonthlyWorkoutsToFirestore() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let monthKey = selectedDate.monthAndYearFormat()

        // Ensure only the current month is saved
        guard selectedDate.isCurrentMonth() else {
            print("Skipping Firestore save: \(monthKey) is not the current month.")
            return
        }

        let workoutsData = currentMonthlyWorkout.map { workout in
            return [
                "title": workout.title,
                "duration": workout.duration,
                "date": workout.date,
                "calories": workout.calories,
                "image": workout.image,
                "tintColor": workout.tintColor.toHexString()
            ]
        }

        let workoutRecord: [String: Any] = [
            "month": monthKey,
            "workouts": workoutsData,
            "lastUpdated": Timestamp(date: Date())
        ]

        do {
            try await Firestore.firestore()
                .collection("monthlyWorkouts")
                .document(userId)
                .collection("history")
                .document(monthKey)
                .setData(workoutRecord, merge: true)

            print("Workouts for \(monthKey) saved successfully in Firestore")
        } catch {
            print("Error saving workouts to Firestore: \(error.localizedDescription)")
        }
    }


    // Fetches past month’s workouts (used for history view)
    func fetchPastMonthWorkouts() async throws {
        let monthKey = selectedDate.monthAndYearFormat()

        try await withCheckedThrowingContinuation({ continuation in
            HealthManager.shared.fetchWorkoutsForMonth(month: selectedDate) { result in
                switch result {
                case .success(let workouts):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        // Only update UI, do not save to Firestore
                        self.workouts.removeAll { $0.date.monthAndYearFormat() == monthKey }
                        self.workouts.append(contentsOf: workouts)
                        self.currentMonthlyWorkout = self.workouts.filter { $0.date.monthAndYearFormat() == monthKey }

                        continuation.resume()
                    }
                case .failure(let error):
                    print("Failed to fetch past month data: \(error.localizedDescription)")
                    continuation.resume()
                }
            }
        }) as Void
    }
}

// MARK: - Date Extension
extension Date {
    /// Returns `true` if the date is in the current month and year.
    func isCurrentMonth() -> Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let selectedMonth = calendar.component(.month, from: self)
        let selectedYear = calendar.component(.year, from: self)
        
        return selectedMonth == currentMonth && selectedYear == currentYear
    }
}

