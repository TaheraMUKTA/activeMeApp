//
//  MonthlyStepsChart.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 16/04/2025.
//

import SwiftUI
import Charts

struct MonthlyStepsChart: View {
    let data: [DailyStepModel]
    let average: Int
    let total: Int

    var body: some View {
        // Labels for X-Axis (e.g. day numbers like "16", "17", ...)
        let labels = getLast30DayLabels()

        let axisIndices = Array(0..<labels.count).filter { $0 % 4 == 0 }    // Show fewer labels

        VStack {
            // Top section showing total and average
            ChartDataView(average: average, total: total)

            // Bar chart for daily steps
            Chart {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, entry in
                    BarMark(
                        x: .value("Day Index", index),
                        y: .value("Steps", entry.count)
                    )
                    .cornerRadius(5)
                    .foregroundStyle(.purple.opacity(0.8))
                }
            }
            .chartXAxis {
                AxisMarks(values: axisIndices) { index in
                    if let indexInt = index.as(Int.self), indexInt < labels.count {
                        AxisValueLabel {
                            Text(labels[indexInt])    // Show label for every 4th bar
                        }
                    }
                }
            }
            .chartXScale(domain: 0...(Double(labels.count) - 0.2))
            .chartPlotStyle { plot in
                plot
                    .padding(.trailing, 0)
            }
            .chartYScale(domain: 0...(Double(data.map(\.count).max() ?? 0) * 1.2))   // Dynamic height
            .padding(.horizontal, 10)
        }
    }
}
