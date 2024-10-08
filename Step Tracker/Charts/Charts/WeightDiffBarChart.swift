//
//  WeightBarChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 28/06/24.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        let chartType: ChartType = .weightDiffBar
        
        ChartContainer(chartType: chartType) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, chartType: chartType)
                }
                
                ForEach(chartData) { weightDiff in
                    Plot {
                        BarMark(
                            x: .value("Date", weightDiff.date, unit: .day),
                            y: .value("Weights",weightDiff.value)
                        )
                        .foregroundStyle(weightDiff.value > 0 ? Color.positiveWeightColor.gradient : Color.negativeWeightColor.gradient)
                        .opacity(rawSelectedDate == nil || weightDiff.date == selectedData?.date ? 1 : 0.3)
                    }
                    .accessibilityLabel(weightDiff.date.weekdayTitle)
                    .accessibilityValue("\(weightDiff.value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always()))) pounds")
                    
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.secondary.opacity(0.3))
                    
                    AxisValueLabel()
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.bar",
                        title: "No Data",
                        description: "There is no weight count data from the Health App"
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

#Preview("Without data") {
    WeightDiffBarChart(chartData: [])
}

#Preview("With data") {
    WeightDiffBarChart(chartData: MockData.weightsDiffs)
}

