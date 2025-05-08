//
//  HomeView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Charts
import RevenueCat

// Controls the order of fitness activities shown in the grid
let activityDisplayOrder: [String] = [
    "Today Steps",
    "Calories Burned",
    "Active Time",
    "Stand Time",
    "Running",
    "Cycling",
    "Yoga"
]

struct HomeView: View {
    // ViewModels used for health, user, weather, and hydration data
    @StateObject var homeViewModel = HomeViewModel()
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @StateObject var hydrationViewModel = HydrationViewModel()
    
    // Controls for premium paywall and expanded activity grid
    @State var showPaywall = false
    @State var showAllActivities = false
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    //let isPremiumUser = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    
                    // Greeting and Edit Button
                    HStack {
                        
                        Text("\(GreetingHelper.greeting) \(viewModel.currentUser?.profileName ?? "User")")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        NavigationLink(destination: GoalEditView().environmentObject(homeViewModel)) {
                            HStack {
                                Text("Edit")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 5)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 25)
                    .padding(.bottom, 15)
                    
                    // MARK: - Weather Info Bar
                    NavigationLink(destination: ForecastView().environmentObject(weatherViewModel)) {
                        WeatherView()     // Shows current weather & 7-day forecast
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // MARK: - Health Summary (Calories, Active Time, Stand)
                    VStack(alignment: .leading, spacing: 5) {
                        // Calories Burned - Line Chart
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Calories")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.red.opacity(0.6))
                                Text("\(homeViewModel.calories)/\(homeViewModel.caloriesGoal) kcal")
                                    .bold()
                            }
                            .frame(width: 110)
                            .padding()
                            
                            LineChartView(data: homeViewModel.todayCalories, color: .red)
                                .frame(width: 230, height: 60)
                                .padding(.horizontal, 10)
                            
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, 30)
                        
                        Spacer()
                        
                        // Active Minutes - Bar Chart
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Active")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                Text("\(homeViewModel.exercise)/\(homeViewModel.activeGoal) mins")
                                    .bold()
                            }
                            .frame(width: 110)
                            .padding()
                            
                            BarChartView(data: homeViewModel.todayActiveMinutes, color: .green)
                                .frame(width: 230, height: 60)
                                .padding(.horizontal, 10)
                            
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, -50)
                        .padding(.bottom, 15)
                        
                        // Stand Time - Circular Progress
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Stand")
                                    .font(.headline)
                                    .bold()
                                    .foregroundColor(.blue.opacity(0.8))
                                Text("\(homeViewModel.stand)/\(homeViewModel.standGoal) hours")
                                    .bold()
                            }
                            .frame(width: 110)
                            .padding()
                            
                            ProgressCircleView(progress: homeViewModel.stand, goal: homeViewModel.standGoal, color: .blue.opacity(0.6))
                                .padding(.all, 55)
                            
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, -40)
                    }
                    
                    // MARK: - Hydration Summary Section
                    NavigationLink(destination: HydrationTrackerView(hydrationViewModel: hydrationViewModel)) {
                        HydrationSummaryView(hydrationViewModel: hydrationViewModel)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)

                    // MARK: - Fitness Activity Cards
                    HStack {
                        Text("Fitness Activity")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button {
                            // show more or less activity cards, restricted by subscription
                            if isPremiumUser {
                                showAllActivities.toggle()
                            } else {
                                showPaywall = true
                            }
                        } label: {
                            Text(showAllActivities ? "Show less" : "Show more")
                                .padding(.all, 10)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
                                .cornerRadius(18)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    
                    // Activity Cards Grid
                    if !homeViewModel.activities.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                            ForEach(
                                homeViewModel.activities
                                    .sorted { a, b in
                                        (activityDisplayOrder.firstIndex(of: a.title) ?? Int.max) <
                                        (activityDisplayOrder.firstIndex(of: b.title) ?? Int.max)
                                    }
                                    .prefix(showAllActivities ? 10 : 4),
                                id: \.title
                            ) { activity in
                                ActivityCardView(activity: activity)
                                
                            }
                        }
                        .padding(.horizontal, 25)
                        
                    } else {
                        //show placeholder when there is no data
                        VStack {
                            Text("No activity data available")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    // MARK: - Recent Workouts Section
                    HStack {
                        Text("Recent Workouts")
                            .font(.title2)
                        
                        Spacer()
                        
                        if isPremiumUser{
                            NavigationLink {
                                MonthlyWorkoutView()
                            } label: {
                                Text("Show more")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
                                    .cornerRadius(18)
                            }
                        } else {
                            Button {
                                showPaywall = true
                            } label: {
                                Text("Show more")
                                    .padding(.all, 10)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.9))
                                    .cornerRadius(18)
                            }
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .padding(.top)
                    
                    // Workout Cards List
                    LazyVStack {
                        if !homeViewModel.workouts.isEmpty {
                            ForEach(homeViewModel.workouts, id: \.id) { workout in
                                WorkoutCardView(workout: workout)
                                
                            }
                        } else {
                            //show placeholder when there is no data
                            VStack {
                                Text("No Recent Workouts available")
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                        }
                    }
                    .padding(.bottom)
                    .padding(.horizontal, 10)
                }
            }
        }
        // MARK: - View Load Tasks
        .onAppear {
            Task {
                // Load latest user and health data
                await homeViewModel.fetchUserGoals()
                await homeViewModel.refreshAllData()
                await weatherViewModel.fetchWeatherDataForCity(city: weatherViewModel.newLocation)
                await viewModel.refreshSubscriptionStatus()
                
                // Fetch hydration-related inputs
                hydrationViewModel.fetchUserWeight()
                hydrationViewModel.fetchActiveMinutes()
                hydrationViewModel.fetchWeatherTemperature()
                
                // Refresh subscription status from RevenueCat
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    let isActive = customerInfo.entitlements["Subscription"]?.isActive == true
                            isPremiumUser = isActive

                    // update Firestore
                    await viewModel.updateSubscriptionStatusInFirestore(isActive: isActive)
                } catch {
                    print("Failed to refresh subscription status: \(error)")
                }
                
                DispatchQueue.main.async {
                    homeViewModel.objectWillChange.send()
                }
            }
        }
        // Listen to data changes and errors
        .onReceive(homeViewModel.objectWillChange) { _ in
            print("HomeViewModel changed, refreshing UI")
        }
        .alert("Oops", isPresented: $homeViewModel.presentError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("There was an issue fetching your health data. Some health tracking requires an Apple Watch.")
        }
        // show Paywall sheet for non-premium users
        .sheet(isPresented: $showPaywall) {
            PayView()
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(WeatherViewModel())
    }
}
