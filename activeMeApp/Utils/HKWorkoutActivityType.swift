//
//  HKWorkoutActivityType.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 05/02/2025.
//

import Foundation
import HealthKit
import SwiftUI

extension HKWorkoutActivityType {

    /*
     Simple mapping of available workout types to a human readable name.
     */
    var name: String {
        switch self {
        case .americanFootball:             return "American Football"
        case .archery:                      return "Archery"
        case .australianFootball:           return "Australian Football"
        case .badminton:                    return "Badminton"
        case .baseball:                     return "Baseball"
        case .basketball:                   return "Basketball"
        case .bowling:                      return "Bowling"
        case .boxing:                       return "Boxing"
        case .climbing:                     return "Climbing"
        case .crossTraining:                return "Cross Training"
        case .curling:                      return "Curling"
        case .cycling:                      return "Cycling"
        case .dance:                        return "Dance"
        case .danceInspiredTraining:        return "Dance Inspired Training"
        case .elliptical:                   return "Elliptical"
        case .equestrianSports:             return "Equestrian Sports"
        case .fencing:                      return "Fencing"
        case .fishing:                      return "Fishing"
        case .functionalStrengthTraining:   return "Functional Strength Training"
        case .golf:                         return "Golf"
        case .gymnastics:                   return "Gymnastics"
        case .handball:                     return "Handball"
        case .hiking:                       return "Hiking"
        case .hockey:                       return "Hockey"
        case .hunting:                      return "Hunting"
        case .lacrosse:                     return "Lacrosse"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind and Body"
        case .mixedMetabolicCardioTraining: return "Mixed Metabolic Cardio Training"
        case .paddleSports:                 return "Paddle Sports"
        case .play:                         return "Play"
        case .preparationAndRecovery:       return "Preparation and Recovery"
        case .racquetball:                  return "Racquetball"
        case .rowing:                       return "Rowing"
        case .rugby:                        return "Rugby"
        case .running:                      return "Running"
        case .sailing:                      return "Sailing"
        case .skatingSports:                return "Skating Sports"
        case .snowSports:                   return "Snow Sports"
        case .soccer:                       return "Soccer"
        case .softball:                     return "Softball"
        case .squash:                       return "Squash"
        case .stairClimbing:                return "Stair Climbing"
        case .surfingSports:                return "Surfing Sports"
        case .swimming:                     return "Swimming"
        case .tableTennis:                  return "Table Tennis"
        case .tennis:                       return "Tennis"
        case .trackAndField:                return "Track and Field"
        case .traditionalStrengthTraining:  return "Traditional Strength Training"
        case .volleyball:                   return "Volleyball"
        case .walking:                      return "Walking"
        case .waterFitness:                 return "Water Fitness"
        case .waterPolo:                    return "Water Polo"
        case .waterSports:                  return "Water Sports"
        case .wrestling:                    return "Wrestling"
        case .yoga:                         return "Yoga"

        // iOS 10
        case .barre:                        return "Barre"
        case .coreTraining:                 return "Core Training"
        case .crossCountrySkiing:           return "Cross Country Skiing"
        case .downhillSkiing:               return "Downhill Skiing"
        case .flexibility:                  return "Flexibility"
        case .highIntensityIntervalTraining:    return "High Intensity Interval Training"
        case .jumpRope:                     return "Jump Rope"
        case .kickboxing:                   return "Kickboxing"
        case .pilates:                      return "Pilates"
        case .snowboarding:                 return "Snowboarding"
        case .stairs:                       return "Stairs"
        case .stepTraining:                 return "Step Training"
        case .wheelchairWalkPace:           return "Wheelchair Walk Pace"
        case .wheelchairRunPace:            return "Wheelchair Run Pace"

        // iOS 11
        case .taiChi:                       return "Tai Chi"
        case .mixedCardio:                  return "Mixed Cardio"
        case .handCycling:                  return "Hand Cycling"

        // iOS 13
        case .discSports:                   return "Disc Sports"
        case .fitnessGaming:                return "Fitness Gaming"

        // Catch-all
        default:                            return "Other"
        }
    }
    
    var image: String {
            switch self {
            case .americanFootball: return "football.fill"
            case .archery: return "target"
            case .australianFootball: return "sportscourt"
            case .badminton: return "figure.badminton"
            case .baseball: return "baseball.fill"
            case .basketball: return "basketball.fill"
            case .bowling: return "figure.bowling"
            case .boxing: return "figure.boxing"
            case .climbing: return "figure.stairs"
            case .crossTraining: return "figure.strengthtraining.traditional"
            case .cycling: return "figure.outdoor.cycle"
            case .dance: return "figure.dance"
            case .elliptical: return "figure.elliptical"
            case .fencing: return "figure.fencing"
            case .fishing: return "fish"
            case .functionalStrengthTraining: return "figure.strengthtraining.functional"
            case .golf: return "figure.golf"
            case .gymnastics: return "figure.gymnastics"
            case .hiking: return "figure.hiking"
            case .hockey: return "hockey.puck"
            case .martialArts: return "figure.martial.arts"
            case .rowing: return "figure.rowing"
            case .rugby: return "sportscourt"
            case .running: return "figure.run"
            case .skatingSports: return "figure.skating"
            case .snowSports: return "snowflake"
            case .soccer: return "soccerball"
            case .softball: return "figure.softball"
            case .swimming: return "figure.pool.swim"
            case .tableTennis: return "figure.tabletennis"
            case .tennis: return "figure.tennis"
            case .trackAndField: return "figure.track.and.field"
            case .traditionalStrengthTraining: return "dumbbell"
            case .volleyball: return "figure.volleyball"
            case .walking: return "figure.walk"
            case .waterSports: return "figure.surfing"
            case .yoga: return "figure.yoga"
            case .highIntensityIntervalTraining: return "flame.fill"
            case .kickboxing: return "figure.kickboxing"
            case .pilates: return "figure.pilates"
            case .taiChi: return "figure.taichi"
            case .mixedCardio: return "heart.fill"
            default: return "questionmark.circle"
            }
        }
    
    var color: Color {
            switch self {
            case .americanFootball: return .brown
            case .archery: return .blue
            case .australianFootball: return .green
            case .badminton: return .purple
            case .baseball: return .red
            case .basketball: return .orange
            case .bowling: return .gray
            case .boxing: return .black
            case .climbing: return .yellow
            case .crossTraining: return .pink
            case .cycling: return .cyan
            case .dance: return .mint
            case .elliptical: return .teal
            case .fencing: return .indigo
            case .fishing: return .blue
            case .functionalStrengthTraining: return .red
            case .golf: return .green
            case .gymnastics: return .purple
            case .hiking: return .brown
            case .hockey: return .gray
            case .martialArts: return .black
            case .rowing: return .blue
            case .rugby: return .red
            case .running: return .orange
            case .skatingSports: return .cyan
            case .snowSports: return .white
            case .soccer: return .green
            case .softball: return .yellow
            case .swimming: return .blue
            case .tableTennis: return .red
            case .tennis: return .green
            case .trackAndField: return .orange
            case .traditionalStrengthTraining: return .gray
            case .volleyball: return .yellow
            case .walking: return .purple
            case .waterSports: return .cyan
            case .yoga: return .mint
            case .highIntensityIntervalTraining: return .pink
            case .kickboxing: return .red
            case .pilates: return .purple
            case .taiChi: return .teal
            case .mixedCardio: return .red
            default: return .green
            }
        }

}
