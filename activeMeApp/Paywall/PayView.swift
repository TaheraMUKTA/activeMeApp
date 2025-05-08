//
//  PayView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 17/03/2025.
//
//

import SwiftUI
    
struct PayView: View {
    @Environment(\.dismiss) var dismiss    // Used to close the paywall view
    @StateObject var payViewModel = PayViewModel()   // Manages purchasing logic
    @State private var showTerms = false
    @State private var showPrivacy = false
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false    // Stores user's premium status
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                Text("Premium Membership")
                    .font(.title)
                    .bold(true)
                Text("For the Active You!")
                    .font(.headline)
                
                Spacer()
                // Feature Highlights
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                            .font(.title)
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            .padding(.trailing, 8)
                        Text("Boost your energy and enhance vitality through regular exercise.")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 6)
                    
                    HStack {
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .font(.title)
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            .padding(.trailing, 8)
                        Text("Track your monthly activity and workout progress with ease.")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 6)
                    
                    HStack {
                        Image(systemName: "person.3.fill")
                            .font(.title2)
                            .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            .padding(.trailing, 8)
                        Text("Be part of a thriving community transforming their lifestyles.")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 6)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                // Subscription Options
                VStack(spacing: 15) {
                    if let offering = payViewModel.currentOffering {
                        ForEach(offering.availablePackages) { package in
                            Button {
                                Task {
                                    do {
                                        try await payViewModel.purchase(package: package)    // Initiate purchase
                                        isPremiumUser = true    // Store status locally
                                        dismiss()    // Close the view
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Text(package.storeProduct.subscriptionPeriod?.durationTitle ?? "Subscription")
                                    Text(package.storeProduct.localizedPriceString)
                                }
                                .foregroundColor(.white)
                                .bold(true)
                                .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .frame(height: 70)
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.8))
                            )
                        }
                    }
                }
                .padding(.horizontal, 40)
                // Restore Purchases
                Button {
                    Task {
                        do {
                            try await payViewModel.restorePurchases()   // Restore previous purchases
                            isPremiumUser = true
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .foregroundColor(.green)
                        .underline()
                }
                
                Spacer()
                // Legal useful links
                HStack(spacing: 12) {
                    NavigationLink(destination: ConditionView()) {
                        Text("Terms and Conditions")
                            .bold(true)
                    }
                    Circle()
                        .fill(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.8))
                        .frame(width: 10, height: 10)
                        .padding(1.5)
                    NavigationLink(destination: PrivacyView()) {
                        Text("Privacy Policy")
                            .bold(true)
                    }
                }
                .foregroundColor(.green)
                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top)
            .sheet(isPresented: $showTerms) {
                ConditionView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyView()
            }
        }
    }
}

struct PayView_Previews: PreviewProvider {
    static var previews: some View {
        PayView()
            
    }
}
