//
//  BarChartView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 10/02/2025.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var data: [Double?]
    var color: Color
    
    var body: some View {
        Chart {
            ForEach(0..<data.count, id: \.self) { hour in
                if let value = data[hour], hour <= Calendar.current.component(.hour, from: Date()), value > 0 {
                    BarMark(
                        x: .value("Hour", hour),
                        y: .value("Active Minutes", value)
                    )
                    .cornerRadius(1)
                    .foregroundStyle(LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.4)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    }
                }
            }
            .chartXAxis {
                        AxisMarks(values: .stride(by: 6)) { value in
                            AxisValueLabel(formatHour(value: value))
                        }
        }
        .frame(height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(1)
        .shadow(color: color.opacity(0.3), radius: 2) // Soft shadow
                
    }
        func formatHour(value: AxisValue) -> String {
                guard let hour = value.as(Int.self) else { return "" }
                let formatter = DateFormatter()
                formatter.dateFormat = "ha"
                return formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date())
            }
}


struct BarChartView_Previews: PreviewProvider {
    static var previews: some View {
        BarChartView(data: [0, 0, 5, 10, 30, 20, 0, 0, 15, 40, 20, 25, 30, 0, 0, 10, 50, 30, 20, 0, 0, 0, 5, 10], color: .green)
            
    }
}

