//
//  ForecastView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack {
                // Background
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .center, spacing: 10) {
                    // City and Date
                    VStack {
                        Text(weatherViewModel.weatherData?.name ?? "Loading...")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        if let weather = weatherViewModel.weatherData {
                            Text(DateFormatterUtils.formattedDateWithFullMonth(from: Date()))
                                .font(.subheadline)
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                .bold()
                            // Weather Icon & Description
                            VStack(spacing: 2) {
                                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.weather.first?.icon ?? "01d")@2x.png")) { image in
                                    image.resizable()
                                        .frame(width: 90, height: 90)
                                } placeholder: {
                                    ProgressView()
                                }
                                
                                Text(weather.weather.first?.description.capitalized ?? "N/A")
                                    .font(.headline)
                                    .italic()
                            }
                            .padding(.bottom, 5)
                            // Feels Like Temperature
                            Text("Feels like: \(Int(weather.main.feels_like))°C")
                                .font(.subheadline)
                                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                                .bold()
                        }
                    }
                    .padding(.vertical, 10)
                    
                    // MARK: - Weather Stats Box
                    if let weather = weatherViewModel.weatherData {
                        VStack(alignment: .center, spacing: 10) {
                            WeatherStatRow(icon: "thermometer" , label: "High: \(Int(weather.main.temp + 2))°C   Low: \(Int(weather.main.temp - 2))°C")
                            WeatherStatRow(icon: "wind", label: "Wind Speed: \(weather.wind.speed) m/s")
                            WeatherStatRow(icon: "humidity.fill", label: "Humidity: \(weather.main.humidity)%")
                            WeatherStatRow(icon: "gauge", label: "Pressure: \(weather.main.pressure) hPa")
                        }
                        .fontWeight(.semibold)
                        .frame(width: 330)
                        .padding(20)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
                    }
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 5)
            
            VStack(spacing: 5){
                // Daily Weather Views
                DailyWeatherView()
                   
            }
        }
        .padding(.bottom, 5)
    }
}

// Helper View for Weather Stats
struct WeatherStatRow: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .resizable()
                .frame(width: 25, height: 25)
                .padding(.leading, 25)
                .foregroundColor(Color(red: 15/255, green: 174/255, blue: 1/255))
                .padding(.leading, 5)
            Text(label)
        }
    }
}

#Preview {
    ForecastView()
        .environmentObject(WeatherViewModel())
}
