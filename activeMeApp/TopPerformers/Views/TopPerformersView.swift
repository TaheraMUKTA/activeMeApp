//
//  TopPerformersView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct TopPerformersUsers: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let username: String
    let count: Int
}


class TopPerformersViewModel: ObservableObject {
    var mockData = [
        TopPerformersUsers(id: 1, createdAt: "", username: "Tahera", count: 7678),
        TopPerformersUsers(id: 2, createdAt: "", username: "Mukta", count: 7478),
        TopPerformersUsers(id: 3, createdAt: "", username: "Tamim", count: 7378),
        TopPerformersUsers(id: 4, createdAt: "", username: "Foysal", count: 7278),
        TopPerformersUsers(id: 5, createdAt: "", username: "Meera", count: 7178),
        TopPerformersUsers(id: 6, createdAt: "", username: "Mohammad", count: 7078),
        TopPerformersUsers(id: 7, createdAt: "", username: "Tasnim", count: 6878),
        TopPerformersUsers(id: 8, createdAt: "", username: "Motaher", count: 6678),
        TopPerformersUsers(id: 9, createdAt: "", username: "Hossain", count: 6378),
        TopPerformersUsers(id: 10, createdAt: "", username: "Tanny", count: 6178)
    ]
    
}


struct TopPerformersView: View {
    @StateObject var viewModel = TopPerformersViewModel()
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
            .foregroundColor(.green)
            .padding(.horizontal, 20)
            
            ScrollView {
                ForEach(viewModel.mockData) { user in
                    HStack {
                        Text("\(user.id). ")
                        Text("\(user.username)")
                            .font(.headline)
                        Spacer()
                        Text("\(user.count)")
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
        .fullScreenCover(isPresented: $showPage) {
            BoardPageView()
        }
        
    }
}

struct TopPerformersView_Previews: PreviewProvider {
    static var previews: some View {
        TopPerformersView(showPage: .constant(false))
            
    }
}
