//
//  YearlyActiveChart.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 16/04/2025.
//

import SwiftUI
import Charts

struct YearlyActiveChart: View {
    let data: [MonthlyActiveModel]
    let average: Int
    let total: Int

    var body: some View {
        VStack {
            // Top section showing total and average
            ChartDataView(average: average, total: total)

            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Month", Double(item.position) + 0.5),    // Smooths bar alignment
                        y: .value("Active Time", item.count)
                    )
                    .cornerRadius(5)
                    .foregroundStyle(.green.opacity(0.8))
                }
            }
            // Defines spacing on x-axis
            .chartXScale(domain: 0.2...12)
            .chartXAxis {
                let months = getLast12Months()
                AxisMarks(values: Array(0...11)) { value in
                    AxisValueLabel {
                        if let index = value.as(Int.self), index < months.count {
                            Text(months[index])    // Month name as label
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
        }
    }
}

