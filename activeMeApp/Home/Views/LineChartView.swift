//
//  LineChartView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 10/02/2025.
//

import SwiftUI
import Charts

struct LineChartView: View {
    var data: [Double]
    var color: Color

    var body: some View {
        Chart {
            ForEach(0..<24, id: \.self) { hour in
                        LineMark(
                            x: .value("Hour", hour),
                            y: .value("Calories", data[hour])
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(color.opacity(0.9))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                    
                        if data[hour] > 0 {
                            AreaMark(
                                x: .value("Hour", hour),
                                yStart: .value("Min", 0),
                                yEnd: .value("Calories", data[hour])
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.05)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                        }
                    }
                }
                .frame(height: 100)
                .background(Color(.systemBackground))
                .cornerRadius(1)
                .shadow(color: color.opacity(0.3), radius: 2)
    }
}

#Preview {
    LineChartView(data: [50.0, 500.0, 300.0, 900.0, 1465.0], color: .red)
}
