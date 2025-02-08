//
//  ChampionsView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI

struct ChampionsUsers: Codable, Identifiable {
    let id: Int
    let createdAt: String
    let username: String
    let count: Int
}


class ChampionsViewModel: ObservableObject {
    var mockData = [
        ChampionsUsers(id: 1, createdAt: "", username: "Tahera", count: 7678),
        ChampionsUsers(id: 2, createdAt: "", username: "Mukta", count: 7478),
        ChampionsUsers(id: 3, createdAt: "", username: "Tamim", count: 7378),
        ChampionsUsers(id: 4, createdAt: "", username: "Foysal", count: 7278),
        ChampionsUsers(id: 5, createdAt: "", username: "Meera", count: 7178),
        ChampionsUsers(id: 6, createdAt: "", username: "Mohammad", count: 7078),
        ChampionsUsers(id: 7, createdAt: "", username: "Tasnim", count: 6878),
        ChampionsUsers(id: 8, createdAt: "", username: "Motaher", count: 6678),
        ChampionsUsers(id: 9, createdAt: "", username: "Hossain", count: 6378),
        ChampionsUsers(id: 10, createdAt: "", username: "Tanny", count: 6178)
    ]
    
}


struct ChampionsView: View {
    @StateObject var viewModel = ChampionsViewModel()
    @Binding var showPage: Bool
    
    var body: some View {
        VStack {
            Text("Champions")
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

struct ChampionsView_Previews: PreviewProvider {
    static var previews: some View {
        ChampionsView(showPage: .constant(false))
            
    }
}
