//
//  PayViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 28/03/2025.
//

import Foundation
import SwiftUI
import RevenueCat

class PayViewModel: ObservableObject {
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false    // Stores if the user is premium
    @Published var currentOffering: Offering?    // Holds the current available subscription offer
    init() {
        // Fetch available offerings from RevenueCat
        Purchases.shared.getOfferings { (offerings, error) in
           if let offering = offerings?.current {
                DispatchQueue.main.async {
                    self.currentOffering = offering
                    
                }
            }
        }
    }
    
    // MARK: - Purchase Subscription
    func purchase(package: Package) async throws {
        // Try purchasing the selected subscription package
        let result = try await Purchases.shared.purchase(package: package)
        // Check if the subscription is now active
        isPremiumUser = result.customerInfo.entitlements["Subscription"]?.isActive == true
    }
    
    // MARK: - Restore Previous Purchase
    func restorePurchases() async throws {
        // Restore any existing subscriptions
        let customerInfo = try await Purchases.shared.restorePurchases()
        // If the subscription is not active after restore, throw error
        if customerInfo.entitlements["Subscription"]?.isActive != true {
           throw URLError(.badURL)
        }
    }
}
