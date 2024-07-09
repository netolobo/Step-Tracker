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
        ChartContainer(
            title: "Weight",
            symbol: "figure",
            subtitle: "Avg: 180 lbs",
            context: .weight,
            isNave: false) {
            
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight count data from the Health App")
            } else {
                Chart {
                    if let selectedData {
                        RuleMark(x: .value("Selected Data", selectedData.date, unit: .day))
                            .foregroundStyle(.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(
                                position: .top,
                                spacing: 0,
                                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { ChartAnnotationView(data: selectedData, context: .weight) }
                    }

                    ForEach(chartData) { weightDiff in
                        BarMark(
                            x: .value("Date", weightDiff.date, unit: .day),
                            y: .value("Weights",weightDiff.value)
                        )
                        .foregroundStyle(weightDiff.value > 0 ? Color.indigo.gradient : Color.mint.gradient)
                        .opacity(rawSelectedDate == nil || weightDiff.date == selectedData?.date ? 1 : 0.3)
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

#Preview {
    WeightDiffBarChart(chartData: MockData.weightsDiffs)
}
