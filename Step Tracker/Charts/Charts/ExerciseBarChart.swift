//
//  ExerciseBarChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 13/08/24.
//

import SwiftUI
import Charts

struct ExerciseBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)    }
    
    var averageExerciseTime: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    var body: some View {
        let chartType: ChartType = .exerciseBar(average: averageExerciseTime)
        
        ChartContainer(chartType: chartType) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .activity)
                }
                
                if !chartData.isEmpty {
                    RuleMark(y: .value("Average", averageExerciseTime))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                        .accessibilityHidden(true)
                }
                
                ForEach(chartData) { steps in
                    Plot {
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Minutes",steps.value)
                        )
                        .foregroundStyle(.exerciseColor.gradient)
                        .opacity(rawSelectedDate == nil || steps.date == selectedData?.date ? 1 : 0.3)
                    }
                    .accessibilityLabel(steps.date.accessibilityDate)
                    .accessibilityValue("\(Int(steps.value)) minutes")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
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
                        description: "There is no exercise time data from the Health App"
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

#Preview("With data") {
    ExerciseBarChart(chartData: MockData.exercise)
}

#Preview("Empty data") {
    ExerciseBarChart(chartData: [])
}
