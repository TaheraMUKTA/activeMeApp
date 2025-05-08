//
//  WeatherViewModel.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import Foundation
import SwiftUI
import CoreLocation

class WeatherViewModel: ObservableObject {
    
    // MARK: - Published Variables
    @Published var weatherData: Weather? // Current weather data
    @Published var dailyWeatherData: [DailyWeather] = [] // 7-day forecast
    @Published var newLocation: String = "London" // Default location
    @Published var hasError: Bool = false // Error tracking
    @Published var errorMessage: String = "" // Error message

    // API keys
    private let apiKey = "3cf82208c8102aa6f5d51e744d7d19c9"
    private let dailyWeatherApiKey = "5502b4d33a3a968c423c43343876e441"

    // MARK: - Initializer
    init() {
        Task {
            await fetchWeatherDataForCity(city: "London")
        }
    }

    // MARK: - Fetch Coordinates for a City
    func getCoordinatesForCity(city: String) async -> CLLocationCoordinate2D? {
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(city)
            if let location = placemarks.first?.location {
                return location.coordinate
            }
        } catch {
            updateError(message: "Failed to fetch coordinates for \(city).")
        }
        return nil
    }
    

    // MARK: - Fetch Weather Data for a City
    func fetchWeatherDataForCity(city: String) async {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.geocodeAddressString(city)
            if let placemark = placemarks.first,
               let coordinate = placemark.location?.coordinate {
                
                let commonCityName = getCommonCityName(from: placemark)
                
                await fetchWeatherData(lat: coordinate.latitude, lon: coordinate.longitude, overrideCityName: commonCityName)
                await fetchDailyWeather(lat: coordinate.latitude, lon: coordinate.longitude)
            } else {
                updateError(message: "Couldn't determine location.")
            }
        } catch {
            updateError(message: "Failed to fetch coordinates for \(city).")
        }
    }

    // to get the common city name
    func getCommonCityName(from placemark: CLPlacemark) -> String {
        if let city = placemark.locality {
            return city // Usually the city/town
        } else if let district = placemark.subAdministrativeArea {
            return district
        } else if let state = placemark.administrativeArea {
            return state
        } else if let country = placemark.country {
            return country
        } else {
            return "Unknown"
        }
    }
    

    // MARK: - Fetch Current Weather Data
    func fetchWeatherData(lat: Double, lon: Double, overrideCityName: String? = nil) async {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            updateError(message: "Invalid URL for current weather.")
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                updateError(message: "Failed to fetch weather data.")
                return
            }

            var decodedData = try JSONDecoder().decode(Weather.self, from: data)
            
            // Override the name with clean city name if available
            if let name = overrideCityName {
                decodedData = Weather(
                    name: name,
                    main: decodedData.main,
                    wind: decodedData.wind,
                    weather: decodedData.weather,
                    timezone: decodedData.timezone
                )
            }

            await MainActor.run {
                self.weatherData = decodedData
            }

        } catch {
            updateError(message: "Failed to fetch weather data.")
        }
    }



    // MARK: - Fetch Daily Weather Data (7-Day Forecast)
        func fetchDailyWeather(lat: Double, lon: Double) async {
            let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=current,minutely,hourly,alerts&units=metric&appid=\(apiKey)"

            guard let url = URL(string: urlString) else {
                updateError(message: "Invalid URL for daily weather.")
                return
            }

            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    updateError(message: "Failed to fetch daily weather data.")
                    return
                }

                let decodedData = try JSONDecoder().decode(DailyWeatherResponse.self, from: data)

                let dailyData = decodedData.daily.prefix(7).map { day -> DailyWeather in
                    let formattedDay = DateFormatterUtils.formattedDateWithWeekdayAndDay(from: TimeInterval(day.dt))

                    return DailyWeather(
                        day: formattedDay,
                        temperatureDay: "\(Int(day.temp.day))°C",
                        temperatureNight: "\(Int(day.temp.night))°C",
                        condition: day.weather.first?.description.capitalized ?? "Unknown",
                        iconCode: day.weather.first?.icon ?? "01d"
                    )
                }

                await MainActor.run {
                    self.dailyWeatherData = dailyData
                }
            } catch {
                updateError(message: "Failed to fetch daily weather data.")
            }
        }

    // MARK: - Error Handling
    func updateError(message: String) {
        DispatchQueue.main.async {
            self.hasError = true
            self.errorMessage = message
        }
    }
}
