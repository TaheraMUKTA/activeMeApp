//
//  WaterIntakeData.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 29/03/2025.
//

import Foundation

// Minimal model for getting only temperature (e.g. hydration logic)
struct WeatherResponse: Codable {
    let main: MainWeather
}

struct MainWeather: Codable {
    let temp: Double
}
