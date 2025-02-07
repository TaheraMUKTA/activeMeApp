//
//  ChartsDataView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Charts

struct ChartsDataView: View {
    
    @StateObject var viewModel = ChartsDataViewModel()
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
                        ChartDataView(average: viewModel.oneWeekAverage, total: viewModel.oneWeekTotal)
                        Chart {
                            ForEach(viewModel.mockWeekChartData) { data in
                                BarMark(x: .value("Day", viewModel.weekdayString(from: data.date)),  y: .value(viewModel.selectedMetric.rawValue, data.count))
                                    .cornerRadius(5)
                                    .foregroundStyle(viewModel.selectedMetricColor) // <- Dynamic Color

                            }
                        }

                    }
                   
                case .oneMonth:
                    VStack {
                        ChartDataView(average: viewModel.oneMonthAverage, total: viewModel.oneMonthTotal)
                        Chart {
                            ForEach(viewModel.mockOneMonthData) { data in
                                BarMark(x: .value("Day", viewModel.dayOfMonth(from: data.date)), y: .value(viewModel.selectedMetric.rawValue, data.count))
                                    .cornerRadius(5)
                                    .foregroundStyle(viewModel.selectedMetricColor)
                                
                            }
                            
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: 3)) // Show labels every 3 days
                        }
                        .chartXScale(domain: 1...31.8) // Ensures spacing fits properly
                        .padding(.horizontal, 10)
                    }
                                        
                    
                    case .oneYear:
                    VStack {
                        ChartDataView(average: viewModel.oneYearAverage, total: viewModel.oneYearTotal)
                        Chart {
                            ForEach(viewModel.fullYearData) { data in
                                BarMark(
                                    x: .value("Month", Double(Calendar.current.component(.month, from: data.date)) + 0.5), // Shift left
                                    y: .value(viewModel.selectedMetric.rawValue, data.count)
                                )
                                .cornerRadius(5)
                                .foregroundStyle(viewModel.selectedMetricColor)
                            }
                        }
                        .padding(.horizontal, 5)
                        .chartXScale(domain: viewModel.adjustedXScaleRange) // Use ViewModel function
                        .chartXAxis {
                            AxisMarks(values: Array(1...12)) { month in
                                if let monthInt = month.as(Int.self) {
                                    AxisValueLabel {
                                        Text(Calendar.current.monthSymbols[monthInt - 1].prefix(3)) // "Jan", "Feb", "Mar", ...
                                    }
                                }
                            }
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
                    .foregroundColor(selectedChart == option ? .white : viewModel.selectedMetricColor) // Use dynamic color
                    .background(selectedChart == option ? viewModel.selectedMetricColor : Color.clear)
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
            
         
                HStack {
                    ForEach(ChartMetric.allCases, id: \.rawValue) { metric in
                        Button(metric.rawValue) {
                            withAnimation {
                                viewModel.selectedMetric = metric
                            }
                        }
                        .frame(width: 85, height: 50)
                        .foregroundColor(viewModel.selectedMetric == metric ? .white : viewModel.selectedMetricColor)
                        .background(viewModel.selectedMetric == metric ? viewModel.selectedMetricColor : Color.gray.opacity(0.1))
                        .fontWeight(.bold)
                        .cornerRadius(10)
                        .padding(.horizontal, 4)
                    }
                
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .leading, vertical: .top))
    }
}

struct ChartsDataView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsDataView()
    }
}
