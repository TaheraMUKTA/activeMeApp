//
//  LineChartView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 10/02/2025.
//

import SwiftUI
import Charts

struct LineChartView: View {
    var data: [Double?]
    var color: Color

    var body: some View {
        Chart {
            ForEach(0..<data.count, id: \.self) { hour in
                if let value = data[hour], hour <= Calendar.current.component(.hour, from: Date()) {
                    LineMark(
                        x: .value("Hour", hour),
                        y: .value("Calories", value)
                    )
                    .interpolationMethod(.cardinal)
                    .foregroundStyle(color.opacity(0.9))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                  
                        AreaMark(
                            x: .value("Hour", hour),
                            yStart: .value("Min", 0),
                            yEnd: .value("Calories", value)
                        )
                        .interpolationMethod(.cardinal)
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.05)]),
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
            .shadow(color: color.opacity(0.3), radius: 2)
    }
    
    func formatHour(value: AxisValue) -> String {
            guard let hour = value.as(Int.self) else { return "" }
            let formatter = DateFormatter()
            formatter.dateFormat = "ha"
            return formatter.string(from: Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date())
        }
}


struct LineChartView_Previews: PreviewProvider {
    static var previews: some View {
        LineChartView(data: [50.0, 500.0, 300.0, 900.0, 1465.0], color: .red)
            
    }
}
