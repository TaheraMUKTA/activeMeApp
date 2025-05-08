//
//  DailyWeatherView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import SwiftUI

struct DailyWeatherView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    var body: some View {
        VStack {
            // Display loading message if daily weather data is unavailable
            if weatherViewModel.dailyWeatherData.isEmpty {
                Text("Loading daily weather data...")
                    .foregroundColor(.gray)
                    .font(.subheadline)
            } else {
                // Scrollable vertical list for daily weather data
                VStack {
                        
                    ForEach(weatherViewModel.dailyWeatherData) { day in
                        HStack {
                            // Weather Icon
                            AsyncImage(url: URL(string: day.iconURL)) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                            } placeholder: {
                                ProgressView()
                            }
                                
                            Spacer()
                                
                            // Day and Weather Details
                            VStack {
                                Text(day.day) // Day of the week
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text(day.condition) // Weather condition
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                        
                            }
                                
                            Spacer()
                                
                            // Temperatures
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("Day:")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text(day.temperatureDay)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                                    
                                HStack {
                                    Text("Night:")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text(day.temperatureNight)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.all, 10)
                        .background(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.7))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    DailyWeatherView()
        .environmentObject(WeatherViewModel())
}
