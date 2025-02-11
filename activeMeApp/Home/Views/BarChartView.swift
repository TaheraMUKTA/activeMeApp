//
//  BarChartView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 10/02/2025.
//

import SwiftUI
import Charts

struct BarChartView: View {
    var data: [Double]
    var color: Color
    
    var body: some View {
        Chart {
            ForEach(0..<24, id: \.self) { hour in
                BarMark(
                    x: .value("Hour", hour),
                    y: .value("Active Minutes", data[hour])
                )
                .cornerRadius(1)
                .foregroundStyle(LinearGradient(
                    gradient: Gradient(colors: [color.opacity(0.8), color.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
            }
        }
        .frame(height: 100)
        .background(Color(.systemBackground))
        .cornerRadius(1)
        .shadow(color: color.opacity(0.3), radius: 2) // Soft shadow
                
    }
}

#Preview {
    BarChartView(data: [100.0, 300.0, 500.0, 700.0, 955.0, 700.0, 300.0, 600.0, 400.0, 455.0], color: .green)
}
