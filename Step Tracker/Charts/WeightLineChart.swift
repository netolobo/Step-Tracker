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
    
    var body: some View {
        let config = ChartContainerConfiguration(title: "Weight",
                                                symbol: "figure",
                                                subtitle: "Avg: 180 lbs",
                                                context: .weight,
                                                isNave: true)
        ChartContainer(config: config) {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.line.downtrend.xyaxis",
                        title: "No Data",
                        description: "There is no weight count data from the Health App"
                    )
                } else {
                    Chart {
                        if let selectedData {
                            ChartAnnotationView(data: selectedData, context: .weight)
                        }
                        ForEach(chartData) { weight in
                            AreaMark(
                                x: .value("Day", weight.date, unit: .day),
                                yStart: .value("Value", weight.value),
                                yEnd: .value("Min Value", minValue)
                            )
                            .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                            
                            LineMark(
                                x: .value("Day", weight.date, unit: .day),
                                y: .value("Value", weight.value)
                            )
                            .foregroundStyle(.indigo)
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                        }
                        
                        RuleMark(y: .value("Goal", 155))
                            .foregroundStyle(.mint)
                            .lineStyle(.init(lineWidth: 1, dash: [5]))
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
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}
