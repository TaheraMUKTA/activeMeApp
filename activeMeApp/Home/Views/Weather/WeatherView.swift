//
//  WeatherView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    var body: some View {
        ZStack {
            // Background rounded box with shadow
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(red: 15/255, green: 174/255, blue: 1/255).opacity(0.68))
                .frame(height: 98)
                .shadow(radius: 5)

            HStack {
                // City name and current date
                VStack(alignment: .leading) {
                    Text(weatherViewModel.weatherData?.name ?? "Loading...")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                    Text(DateFormatterUtils.formattedDateWithFullMonth(from: Date()))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                // Temperature and "feels like" info
                VStack {
                    Text("\(Int(weatherViewModel.weatherData?.main.temp ?? 0))°")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Real feel: \(Int(weatherViewModel.weatherData?.main.feels_like ?? 0))°C")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }

                Spacer()

                // Weather Icon & Description
                VStack {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherViewModel.weatherData?.weather.first?.icon ?? "01d")@2x.png")) { image in
                            image.resizable()
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    Text(weatherViewModel.weatherData?.weather.first?.description.capitalized ?? "Loading...")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 5)
                        .padding(.top, -10)
                }
            }
            .padding(.horizontal, 15)
        }
    }
}

#Preview {
    WeatherView()
        .environmentObject(WeatherViewModel())
}
