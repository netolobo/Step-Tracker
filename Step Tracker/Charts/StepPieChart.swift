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
    var chartData: [WeekDayChartData] = []
    
    var selectedWeekday: WeekDayChartData? {
        guard let rawSelectedChartValue else { return nil }
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return rawSelectedChartValue <= total
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Label("Averages", systemImage: "calendar")
                        .font(.title3.bold())
                        .foregroundColor(.pink)
                    
                    Text("Last 28 Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)
                
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.pie", title: "No Data", description: "There is no step count data from the Health App")
                } else {
                    Chart {
                        ForEach(chartData) { weekDay in
                            SectorMark(
                                angle: .value("Average Steps", weekDay.value),
                                innerRadius: .ratio(0.618),
                                outerRadius: selectedWeekday?.date.weekdayInt == weekDay.date.weekdayInt ? 140: 110,
                                angularInset: 1
                            )
                            .foregroundStyle(.pink.gradient)
                            .cornerRadius(6)
                            .opacity(selectedWeekday?.date.weekdayInt == weekDay.date.weekdayInt ? 1.0 : 0.3)
                        }
                    }
                    .chartAngleSelection(value: $rawSelectedChartValue.animation(.easeInOut))
                    .frame(height: 240)
                    .chartBackground { proxy in
                        GeometryReader { geo in
                            if let plotFrame = proxy.plotFrame {
                                let frame = geo[plotFrame]
                                if let selectedWeekday {
                                    VStack {
                                        Text(selectedWeekday.date.weekdayTitle)
                                            .font(.title3.bold())
                                            .contentTransition(.identity)
                                        
                                        Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                            .contentTransition(.numericText())
                                    }
                                    .position(x: frame.midX, y: frame.midY)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekDayCount(for: MockData.steps))
}
