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
    @Binding var showPage: Bool
    
    var body: some View {
        VStack {
            Text("Top Performers")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
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
            
            ScrollView {
                LazyVStack {
                    ForEach(Array(performersViewModel.performersResult.topten.prefix(10).enumerated()), id: \.element.id) { (index, users) in
                        HStack {
                            Text("\(index + 1).")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(users.profilename)
                                .font(.headline)
                            
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
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task {
                try? await performersViewModel.setTopPerformersData()
            }
        }
        if !acceptedTerms {
            Color.white.opacity(0.95)
                .ignoresSafeArea()

            BoardPageView(showPage: $showPage)
                .transition(.opacity)
        }
    }
}

extension Int {
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
