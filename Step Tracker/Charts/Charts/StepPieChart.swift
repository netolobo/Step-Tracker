//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    @State private var rawSelectedChartValue: Double? = 0
    @State private var selectedDay: Date?
    @State private var lastSelectedValue: Double = 0
    var chartData: [DateValueChartData] = []
    
    var selectedWeekday: DateValueChartData? {
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }
    
    var body: some View {
        let charType: ChartType = .stepWeekdayPie
        
        ChartContainer(chartType: charType) {
            Chart {
                ForEach(chartData) { weekday in
                    SectorMark(
                        angle: .value("Average Steps", weekday.value),
                        innerRadius: .ratio(0.618),
                        outerRadius: selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140: 110,
                        angularInset: 1
                    )
                    .foregroundStyle(.stepsColor.gradient)
                    .cornerRadius(6)
                    .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1.0 : 0.3)
                    .accessibilityLabel(weekday.date.weekdayTitle)
                    .accessibilityValue("\(Int(weekday.value)) steps")
                }
            }
            .chartAngleSelection(value: $rawSelectedChartValue)
            .onChange(of: rawSelectedChartValue) { oldValue, newValue in
                withAnimation(.easeInOut) {
                    guard let newValue else {
                        lastSelectedValue = oldValue ?? 0
                        return
                    }
                    
                    lastSelectedValue = newValue
                }   
            }
            .frame(height: 240)
            .chartBackground { proxy in
                GeometryReader { geo in
                    if let plotFrame = proxy.plotFrame {
                        let frame = geo[plotFrame]
                        if let selectedWeekday {
                            VStack {
                                Text(selectedWeekday.date.weekdayTitle)
                                    .font(.title3.bold())
                                    .animation(.none)
                                
                                Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .contentTransition(.numericText())
                            }
                            .position(x: frame.midX, y: frame.midY)
                            .accessibilityHidden(true)
                        }
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: selectedDay)
            .onChange(of: selectedWeekday) { oldValue, newValue in
                guard let oldValue, let newValue else { return }
                if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                    selectedDay = newValue.date
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(
                        systemImageName: "chart.pie",
                        title: "No Data",
                        description: "There is no step count data from the Health App"
                    )
                }
            }
        }
    }
}

#Preview("With data") {
    StepPieChart(chartData: ChartHelper.averageWeekDayCount(for: MockData.steps))
}

#Preview("Empty data") {
    StepPieChart(chartData: [])
}
