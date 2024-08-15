//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 26/06/24.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var minValue: Double {
        chartData.map{ $0.value }.min() ?? 0 //get the mininum value of the array
    }
    
    var average: Double {
        chartData.map { $0.value }.average
    }
    
    var body: some View {
        let chartType: ChartType = .weightLine(average: average)
        
        ChartContainer(chartType: chartType) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, chartType: chartType)
                }
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.goalColor)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .accessibilityHidden(true)
                
                ForEach(chartData) { weight in
                    Plot {
                        AreaMark(
                            x: .value("Day", weight.date, unit: .day),
                            yStart: .value("Value", weight.value),
                            yEnd: .value("Min Value", minValue)
                        )
                        .foregroundStyle(Gradient(colors: [.weightColor.opacity(0.5), .clear]))
                        
                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(.weightColor)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                    }
                    .accessibilityLabel(weight.date.accessibilityDate)
                    .accessibilityValue("\(weight.value.formatted(.number.precision(.fractionLength(1)))) pounds")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
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
                        systemImageName: "chart.line.downtrend.xyaxis",
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

#Preview("With Data") {
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}

#Preview("Empty Data") {
    WeightLineChart(chartData: [])
}
