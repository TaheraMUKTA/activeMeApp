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
    @State var selectedChart: ChartOptions = .oneWeek     // selected chart default value oneWeek
    @AppStorage("isPremiumUser") var isPremiumUser: Bool = false
    //let isPremiumUser = true
    @State private var showPaywall = false
    @State private var hasShownAlertThisSession = false
    
    // Checks if selected data is empty (used to show error on first load)
    var isSelectedDataEmpty: Bool {
        switch chartViewModel.selectedMetric {
        case .steps:
            return chartViewModel.oneWeekStepData.isEmpty
        case .calories:
            return chartViewModel.oneWeekCaloriesData.isEmpty
        case .active:
            return chartViewModel.oneWeekActiveData.isEmpty
        case .stand:
            return chartViewModel.oneWeekStandData.isEmpty
        }
    }
    
    var body: some View {
        VStack {
            // Title
            Text("Charts")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            // chart area
            ZStack {
                switch selectedChart {
                case .oneWeek:
                    VStack {
                        // Render weekly chart based on selected metric
                        switch chartViewModel.selectedMetric {
                            // calories
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
                            // active time
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
                            
                            //stand time
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
                                ForEach(chartViewModel.oneWeekStepData) { data in
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
                        // Render monthly chart using separate views
                        switch chartViewModel.selectedMetric {
                            // calories
                        case .calories:
                            MonthlyCaloriesChart(
                                data: chartViewModel.oneMonthCaloriesData,
                                average: chartViewModel.oneMonthCaloriesAverage,
                                total: chartViewModel.oneMonthCaloriesTotal
                            )

                            // active time
                        case .active:
                            MonthlyActiveChart(
                                data: chartViewModel.oneMonthActiveData,
                                average: chartViewModel.oneMonthActiveAverage,
                                total: chartViewModel.oneMonthActiveTotal
                            )

                            // stand time
                        case .stand:
                            MonthlyStandChart(
                                data: chartViewModel.oneMonthStandData,
                                average: chartViewModel.oneMonthStandAverage,
                                total: chartViewModel.oneMonthStandTotal
                            )

                            
                        default: // steps as default
                            MonthlyStepsChart(
                                data: chartViewModel.oneMonthStepData,
                                average: chartViewModel.oneMonthAverage,
                                total: chartViewModel.oneMonthTotal
                            )
                        }
                    }
                    
                case .oneYear:
                    VStack {
                        // Render yearly chart using separate views
                        switch chartViewModel.selectedMetric {
                            // calories
                        case .calories:
                            YearlyCaloriesChart(
                                data: chartViewModel.oneYearCaloriesData,
                                average: chartViewModel.oneYearCaloriesAverage,
                                total: chartViewModel.oneYearCaloriesTotal
                            )

                            // active time
                        case .active:
                            YearlyActiveChart(
                                data: chartViewModel.oneYearActiveData,
                                average: chartViewModel.oneYearActiveAverage,
                                total: chartViewModel.oneYearActiveTotal
                            )

                            // stand time
                        case .stand:
                            YearlyStandChart(
                                data: chartViewModel.oneYearStandData,
                                average: chartViewModel.oneYearStandAverage,
                                total: chartViewModel.oneYearStandTotal
                            )

                            
                        default: // Steps as default
                            YearlyStepsChart(
                                data: chartViewModel.oneYearChartData,
                                average: chartViewModel.oneYearAverage,
                                total: chartViewModel.oneYearTotal
                            )
                        }
                    }
                }
            }
            .foregroundColor(.purple.opacity(0.9))
            .frame(maxHeight: 430)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // time frame toggle (week / month / year)
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
            .padding(.bottom, 45)
            
            // metric toggle (steps / calories / active / stand)
            HStack {
                ForEach(ChartMetric.allCases, id: \.rawValue) { metric in
                    Button {
                        if metric == .steps || isPremiumUser {
                            withAnimation {
                                chartViewModel.selectedMetric = metric
                            }
                        } else {
                            showPaywall = true    // Show paywall if not subscribed
                        }
                    } label: {
                        Text(metric.rawValue)
                            .frame(width: 85, height: 50)
                            .foregroundColor(chartViewModel.selectedMetric == metric ? .white : chartViewModel.selectedMetricColor)
                            .background(chartViewModel.selectedMetric == metric ? chartViewModel.selectedMetricColor : Color.gray.opacity(0.1))
                            .fontWeight(.bold)
                            .cornerRadius(10)
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
        // Error if HealthKit access failed or no data available
        .alert("Oops", isPresented: $chartViewModel.presentError) {
            
            Button("OK", role: .cancel) {}
        } message: {
            Text("There was an issue fetching your health data. Please make sure you have allowed access and try again.")
        }
        // Paywall for premium metrics
        .sheet(isPresented: $showPaywall) {
            PayView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
        // Show error alert once if no data was found
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !hasShownAlertThisSession && isSelectedDataEmpty {
                    chartViewModel.presentError = true
                    hasShownAlertThisSession = true
                }
            }
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}

