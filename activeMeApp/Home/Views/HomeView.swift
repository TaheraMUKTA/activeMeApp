//
//  HomeView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Charts

struct HomeView: View {
    @StateObject var homeViewModel = HomeViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(GreetingHelper.greeting) \(viewModel.currentUser?.profileName ?? "User")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                        Button(action: {
                            print("Edit button tapped")
                        }) {
                            Text("Edit")
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                
                    
                    VStack(spacing: 5) {
                            
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.red.opacity(0.6))
                                Text("\(homeViewModel.calories) kcal")
                                    .bold()
                            }
                            .padding()
                            Spacer()
                            
                            LineChartView(data: homeViewModel.todayCalories, color: .red)
                                    .frame(width: 230, height: 60)
                                    .padding(.horizontal, 10)
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                       
                        Spacer()
                        
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Active")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.green.opacity(0.8))
                                    Text("\(homeViewModel.exercise) mins")
                                        .bold()
                                }.padding()
                               
                                Spacer()
                                BarChartView(data: homeViewModel.todayActiveMinutes, color: .green)
                                    .frame(width: 230, height: 60)
                                    .padding(.horizontal, 10)
                                
                            }
                            .padding(.horizontal)
                            .padding(.bottom, -50)
                            
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stand")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.blue.opacity(0.8))
                                Text("\(homeViewModel.stand) hours")
                                    .bold()
                            }
                            .padding(.leading, 15)
                            
                            ProgressCircleView(progress: $homeViewModel.stand, goal: 12, color: .blue)
                                .padding(.all, 70)
                            
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, -65)
                    
                    HStack {
                        Text("Fitness Activity")
                            .font(.title2)
                            .padding()
                        
                        Spacer()
                        
                        Button {
                            print("Show more")
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal)
                    
                    if !homeViewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(spacing: 20), count: 2)) {
                            ForEach(homeViewModel.activities, id: \.title) { activity in
                                ActivityCardView(activity: activity)
                                
                            }
                        }
                        .padding(.horizontal)
                        
                    }
                    
                    HStack {
                        Text("Recent Workouts")
                            .font(.title2)
                            .padding()
                        
                        Spacer()
                        
                        NavigationLink {
                            EmptyView()
                        } label: {
                            Text("Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .background(Color(red: 15/255, green: 174/255, blue: 1/255))
                                .cornerRadius(18)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    LazyVStack {
                        ForEach(homeViewModel.workouts, id: \.id) { workout in
                            WorkoutCardView(workout: workout)
                            
                        }
                    }
                }
                
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
    }
}
