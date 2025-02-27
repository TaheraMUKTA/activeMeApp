//
//  ChartsDataView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Charts
import Foundation

struct ChartsView: View {
    
    @StateObject var chartViewModel = ChartsDataViewModel()
    @State var selectedChart: ChartOptions = .oneWeek
    
    var body: some View {
        VStack {
            Text("Charts")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            ZStack {
                switch selectedChart {
                case .oneWeek:
                    VStack {
                        switch chartViewModel.selectedMetric {
                        case .calories:
                            ChartDataView(average: chartViewModel.oneWeekCaloriesAverage, total: chartViewModel.oneWeekCaloriesTotal)
                            Chart {
                                ForEach(chartViewModel.oneWeekCaloriesData) { data in
                                    BarMark(x: .value("Day", chartViewModel.weekdayString(from: data.date)),
                                            y: .value("Calories", data.calories))
                                        .cornerRadius(5)
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                            }
                        case .active:
                            ChartDataView(average: chartViewModel.oneWeekActiveAverage, total: chartViewModel.oneWeekActiveTotal)
                            Chart {
                                ForEach(chartViewModel.oneWeekActiveData) { data in
                                    BarMark(x: .value("Day", chartViewModel.weekdayString(from: data.date)),
                                            y: .value("Active Time", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.green.opacity(0.8))
                                }
                            }
                        case .stand:
                            ChartDataView(average: chartViewModel.oneWeekStandAverage, total: chartViewModel.oneWeekStandTotal)
                            Chart {
                                ForEach(chartViewModel.oneWeekStandData) { data in
                                    BarMark(x: .value("Day", chartViewModel.weekdayString(from: data.date)),
                                            y: .value("Stand Hours", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                            }
                        default: // steps as default
                            ChartDataView(average: chartViewModel.oneWeekAverage, total: chartViewModel.oneWeekTotal)
                            Chart {
                                ForEach(chartViewModel.oneWeekChartData) { data in
                                    BarMark(x: .value("Day", chartViewModel.weekdayString(from: data.date)),
                                            y: .value("Steps", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.purple.opacity(0.8))
                                }
                            }
                        }
                    }

                case .oneMonth:
                    VStack {
                        switch chartViewModel.selectedMetric {
                        case .calories:
                            ChartDataView(average: chartViewModel.oneMonthCaloriesAverage, total: chartViewModel.oneMonthCaloriesTotal)
                            Chart {
                                ForEach(chartViewModel.oneMonthCaloriesData) { data in
                                    BarMark(x: .value("Day", chartViewModel.dayOfMonth(from: data.date)),
                                            y: .value("Calories", data.calories))
                                        .cornerRadius(5)
                                        .foregroundStyle(.red.opacity(0.8))
                                }
                            }
                            .chartXAxis {
                                let days = getLast30Days()
                                AxisMarks(values: Array(stride(from: 1, to: 31, by: 4))) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 30 {
                                        AxisValueLabel {
                                            Text(days[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .chartXScale(domain: 1...31.8)
                            .padding(.horizontal, 10)
                            
                        case .active:
                            ChartDataView(average: chartViewModel.oneMonthActiveAverage, total: chartViewModel.oneMonthActiveTotal)
                            Chart {
                                ForEach(chartViewModel.oneMonthActiveData) { data in
                                    BarMark(x: .value("Day", chartViewModel.dayOfMonth(from: data.date)),
                                            y: .value("Active Time", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.green.opacity(0.8))
                                }
                            }
                            .chartXAxis {
                                let days = getLast30Days()
                                AxisMarks(values: Array(stride(from: 1, to: 31, by: 4))) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 30 {
                                        AxisValueLabel {
                                            Text(days[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .chartXScale(domain: 1...31.8)
                            .padding(.horizontal, 10)
                            
                        case .stand:
                            ChartDataView(average: chartViewModel.oneMonthStandAverage, total: chartViewModel.oneMonthStandTotal)
                            Chart {
                                ForEach(chartViewModel.oneMonthStandData) { data in
                                    BarMark(x: .value("Day", chartViewModel.dayOfMonth(from: data.date)),
                                            y: .value("Stand Hours", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.blue.opacity(0.8))
                                }
                            }
                            .chartXAxis {
                                let days = getLast30Days()
                                AxisMarks(values: Array(stride(from: 1, to: 31, by: 4))) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 30 {
                                        AxisValueLabel {
                                            Text(days[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .chartXScale(domain: 1...31.8)
                            .padding(.horizontal, 10)
                            
                        default: // steps as default
                            ChartDataView(average: chartViewModel.oneMonthAverage, total: chartViewModel.oneMonthTotal)
                            Chart {
                                ForEach(chartViewModel.oneMonthChartData) { data in
                                    BarMark(x: .value("Day", chartViewModel.dayOfMonth(from: data.date)),
                                            y: .value("Steps", data.count))
                                        .cornerRadius(5)
                                        .foregroundStyle(.purple.opacity(0.8))
                                }
                            }
                            .chartXAxis {
                                let days = getLast30Days()
                                AxisMarks(values: Array(stride(from: 1, to: 31, by: 4))) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 30 {
                                        AxisValueLabel {
                                            Text(days[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .chartXScale(domain: 1...31.8)
                            .padding(.horizontal, 10)
                        }
                    }

                    
                case .oneYear:
                    VStack {
                        switch chartViewModel.selectedMetric {
                        case .calories:
                            ChartDataView(average: chartViewModel.oneYearCaloriesAverage, total: chartViewModel.oneYearCaloriesTotal)
                            Chart {
                                ForEach(chartViewModel.oneYearCaloriesData) { data in
                                    BarMark(
                                        x: .value("Month", Double(Calendar.current.component(.month, from: data.date)) + 0.5),
                                        y: .value("Calories", data.calories)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(.red.opacity(0.8))
                                }
                            }
                            .chartXScale(domain: chartViewModel.adjustedXScaleRange)
                            .chartXAxis {
                                let months = getLast12Months()
                                AxisMarks(values: Array(1...12)) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 12 {
                                        AxisValueLabel {
                                            Text(months[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            
                        case .active:
                            ChartDataView(average: chartViewModel.oneYearActiveAverage, total: chartViewModel.oneYearActiveTotal)
                            Chart {
                                ForEach(chartViewModel.oneYearActiveData) { data in
                                    BarMark(
                                        x: .value("Month", Double(Calendar.current.component(.month, from: data.date)) + 0.5),
                                        y: .value("Active Time", data.count)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(.green.opacity(0.8))
                                }
                            }
                            .chartXScale(domain: chartViewModel.adjustedXScaleRange)
                            .chartXAxis {
                                let months = getLast12Months()
                                AxisMarks(values: Array(1...12)) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 12 {
                                        AxisValueLabel {
                                            Text(months[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            
                        case .stand:
                            ChartDataView(average: chartViewModel.oneYearStandAverage, total: chartViewModel.oneYearStandTotal)
                            Chart {
                                ForEach(chartViewModel.oneYearStandData) { data in
                                    BarMark(
                                        x: .value("Month", Double(Calendar.current.component(.month, from: data.date)) + 0.5),
                                        y: .value("Stand Hours", data.count)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(.blue.opacity(0.8))
                                }
                            }
                            .chartXScale(domain: chartViewModel.adjustedXScaleRange)
                            .chartXAxis {
                                let months = getLast12Months()
                                AxisMarks(values: Array(1...12)) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 12 {
                                        AxisValueLabel {
                                            Text(months[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            
                        default: // Steps as default
                            ChartDataView(average: chartViewModel.oneYearAverage, total: chartViewModel.oneYearTotal)
                            Chart {
                                ForEach(chartViewModel.oneYearChartData) { data in
                                    BarMark(
                                        x: .value("Month", Double(Calendar.current.component(.month, from: data.date)) + 0.5),
                                        y: .value("Steps", data.count)
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(.purple.opacity(0.8))
                                }
                            }
                            .chartXScale(domain: chartViewModel.adjustedXScaleRange)
                            .chartXAxis {
                                let months = getLast12Months()
                                AxisMarks(values: Array(1...12)) { index in
                                    if let indexInt = index.as(Int.self), indexInt > 0 && indexInt <= 12 {
                                        AxisValueLabel {
                                            Text(months[indexInt - 1])
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                    }

                }
            }
            .foregroundColor(.purple.opacity(0.9))
            .frame(maxHeight: 400)
            .padding(.horizontal)
            
            HStack {
                ForEach(ChartOptions.allCases, id:\.rawValue) { option in
                    Button(option.rawValue) {
                        withAnimation {
                            selectedChart = option
                        }
                    }
                    .padding()
                    .frame(width: 85, height: 45)
                    .foregroundColor(selectedChart == option ? .white : chartViewModel.selectedMetricColor) // Use dynamic color
                    .background(selectedChart == option ? chartViewModel.selectedMetricColor : Color.clear)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 50)
            
         
                HStack {
                    ForEach(ChartMetric.allCases, id: \.rawValue) { metric in
                        Button(metric.rawValue) {
                            withAnimation {
                                chartViewModel.selectedMetric = metric
                            }
                        }
                        .frame(width: 85, height: 50)
                        .foregroundColor(chartViewModel.selectedMetric == metric ? .white : chartViewModel.selectedMetricColor)
                        .background(chartViewModel.selectedMetric == metric ? chartViewModel.selectedMetricColor : Color.gray.opacity(0.1))
                        .fontWeight(.bold)
                        .cornerRadius(10)
                        .padding(.horizontal, 4)
                    }
                
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}

