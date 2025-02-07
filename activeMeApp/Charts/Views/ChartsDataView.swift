//
//  ChartsDataView.swift
//  activeMeApp
//
//  Created by Tahera Akter Mukta on 02/02/2025.
//

import SwiftUI
import Charts

struct DailyStepModel: Identifiable {
    let id = UUID()
    let date: Date
    let count: Double
}

enum ChartOptions: String, CaseIterable {
    case oneWeek = "Week"
    case oneMonth = "Month"
    case oneYear = "Year"
}

class ChartsDataViewModel: ObservableObject {
    var mockChartData = [
        DailyStepModel(date: Date(), count: 6780),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), count: 10350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), count: 12350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), count: 15350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), count: 13350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), count: 11350),
        DailyStepModel(date: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(), count: 8350),
        
    ]
    
   
    @Published var mockOneMonthData = [DailyStepModel]()
    
    init() {
        var mockOneMonths = mockDataForDays(days: 30)
        DispatchQueue.main.async {
            self.mockOneMonthData = mockOneMonths
        }
    }
    
    func mockDataForDays(days: Int) -> [DailyStepModel] {
        var mockData = [DailyStepModel]()
        for day in 0..<days {
            let currentDate = Calendar.current.date(byAdding: .day, value: -day, to: Date()) ?? Date()
            let randomStepCount = Int.random(in: 5000...15000)
            let dailyStepData = DailyStepModel(date: currentDate, count: Double(randomStepCount))
            mockData.append(dailyStepData)
        }
        return mockData
    }
}

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
                    Chart {
                        ForEach(viewModel.mockChartData) { data in
                            BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                                .cornerRadius(5)
                        }
                    }
                case .oneMonth:
                    Chart {
                        ForEach(viewModel.mockOneMonthData) { data in
                            BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                                .cornerRadius(5)
                        }
                    }
                case .oneYear:
                    Chart {
                        ForEach(viewModel.mockChartData) { data in
                            BarMark(x: .value(data.date.formatted(), data.date, unit: .day), y: .value("Steps", data.count))
                                .cornerRadius(5)
                            
                        }
                    }
                }
            }
            .foregroundColor(.purple.opacity(0.9))
            .frame(maxHeight: 350)
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
                    .foregroundColor(selectedChart == option ? .white : .purple)
                    .background(selectedChart == option ? .purple.opacity(0.9) : .clear)
                    .cornerRadius(15)
                    .padding(.horizontal)
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
