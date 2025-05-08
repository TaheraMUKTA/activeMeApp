//
//  WeatherData.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 19/03/2025.
//

import Foundation

// Weather data structure for current weather
struct Weather: Codable {
    let name: String
    let main: Main
    let wind: Wind
    let weather: [WeatherCondition]
    let timezone: Int
}

// Add Wind Speed Data Model
struct Wind: Codable {
    let speed: Double // Wind speed in meters per second
}

// Main weather details (temperature, humidity, etc.)
struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
}

// Specific weather conditions (e.g., description, icon)
struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

// Daily weather data structure for display
struct DailyWeather: Identifiable {
    let id = UUID()
    let day: String              // Formatted day, e.g. "Monday 21"
    let temperatureDay: String   // Day temperature, e.g. "32°C"
    let temperatureNight: String // Night temperature, e.g. "29°C"
    let condition: String        // Weather condition, e.g. "Clear Sky"
    let iconCode: String         // Icon code from OpenWeather

    var iconURL: String {
        "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
    }
}


// API Response for Daily Weather
struct DailyWeatherResponse: Codable {
    let daily: [DailyData]
    let timezone_offset: Int? // Offset for timezone adjustments
}

// Daily weather data from API
struct DailyData: Codable {
    let dt: Int      // Date for the forecast
    let temp: DailyTemp // Nested object for day and night temperatures
    let weather: [WeatherCondition]
}

// Temperature for daily forecast
struct DailyTemp: Codable {
    let day: Double
    let night: Double
}
