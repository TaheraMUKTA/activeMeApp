//
//  TopPerformersView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct TopPerformersView: View {
    @StateObject var performersViewModel = TopPerformersViewModel()
    @AppStorage("acceptedTerms") var acceptedTerms: Bool = false
    @State private var showBoardPage: Bool = false
    @Binding var showPage: Bool
    
    var body: some View {
        ZStack {
            VStack {
                // Show agreement page if terms not accepted
                if showBoardPage {
                    BoardPageView(showPage: $showBoardPage)
                } else {
                    VStack {
                        // Title and refresh button
                        ZStack(alignment: .trailing) {
                            Text("Top Performers")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .padding(.top)
                                .frame(maxWidth: .infinity)
                            // Refresh button to reload data manually
                            Button {
                                Task {
                                    await performersViewModel.refreshData()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing)
                                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                            }
                        }
                        // Leaderboard headers
                        HStack {
                            Text("Name")
                                .fontWeight(.bold)
                                .font(.title3)
                            Spacer()
                            Text("Steps")
                                .fontWeight(.bold)
                                .font(.title3)
                        }
                        .padding()
                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                        .padding(.horizontal, 20)
                        
                        // Main leaderboard list
                        ScrollView(showsIndicators: false) {
                            if performersViewModel.performersResult.topten.isEmpty {
                                // Placeholder when no data is available
                                VStack {
                                    Text("No top performer data yet.")
                                        .font(.headline)
                                        .padding(.top, 40)
                                    Text("Be the first one to start moving! 🏃‍♀️")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                LazyVStack {
                                    // Display top 10 performers with rank and steps
                                    ForEach(Array(performersViewModel.performersResult.topten.prefix(10).enumerated()), id: \.element.id) { (index, users) in
                                        HStack {
                                            Text("\(index + 1).")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                            
                                            Text(users.profilename)
                                                .font(.headline)
                                            // Add medals for top 3 ranks
                                            if index == 0 {
                                                Text("👑")
                                            } else if index == 1 {
                                                Text("🥈")
                                            } else if index == 2 {
                                                Text("🥉")
                                            }
                                            
                                            Spacer()
                                            Text("\(users.count.formattedNumberString())")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 20)
                                    }
                                }
                                
                                // Show current user data if not in top 10
                                if let user = performersViewModel.performersResult.user {
                                    Image(systemName: "ellipsis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 46, height: 46)
                                        .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                    HStack {
                                        Text("\(user.profilename.isEmpty ? "Unknown" : user.profilename)")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(user.count.formattedNumberString())")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                }
                                
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .onAppear {
                        Task {
                            try? await performersViewModel.setTopPerformersData()
                        }
                    }
                }
            }
            // Alert if leaderboard loading fails
            .alert("Oops", isPresented: $performersViewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("There was an issue loading the Top Performers data. Please try again later.")
            }
            .onAppear {
                checkIfUserNeedsBoardPage()
            }
        }
    }
    // Checks if the user has agreed to terms, if not shows the BoardPage
    func checkIfUserNeedsBoardPage() {
        if !acceptedTerms {
            showBoardPage = true
        }
    }
}

// MARK: - Formatter Extension for Step Count
extension Int {
    // Formats step counts with comma separators
    func formattedNumberString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

struct TopPerformersView_Previews: PreviewProvider {
    static var previews: some View {
        TopPerformersView(showPage: .constant(false))
            
    }
}
