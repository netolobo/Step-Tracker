//
//  ActivitiesBarChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 12/08/24.
//

import SwiftUI
import Charts

struct StandBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)    }
    
    var averageStandTime: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var body: some View {
        let chartType: ChartType = .standBar(average: averageStandTime)
        
        ChartContainer(chartType: chartType) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, chartType: chartType)
                }
                
                if !chartData.isEmpty {
                    RuleMark(y: .value("Average", averageStandTime))
                        .foregroundStyle(.goalColor)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
                
                ForEach(chartData) { stand in
                    Plot {
                        BarMark(
                            x: .value("Date", stand.date, unit: .day),
                            y: .value("Hours",stand.value)
                        )
                        .foregroundStyle(.standColor.gradient)
                        .opacity(rawSelectedDate == nil || stand.date == selectedData?.date ? 1 : 0.3)
                    }
                    .accessibilityLabel(stand.date.accessibilityDate)
                    .accessibilityValue("\(Int(stand.value)) hours")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No Data",
                        description: "There is no stand hour data from the Health App"
                    )
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}


#Preview("Empty data") {
    StandBarChart(chartData: [])
}

#Preview("With data") {
    StandBarChart(chartData: MockData.stand)
}
