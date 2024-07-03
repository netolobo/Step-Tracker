//
//  StepBarChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import SwiftUI
import Charts


struct StepBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    
    var avgStepCount: Double {
        guard !chartData.isEmpty else { return 0 }
        let totalSteps = chartData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(chartData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                NavigationLink(value: selectedStat) {
                    HStack {
                        VStack(alignment: .leading) {
                            Label("Steps", systemImage: "figure.walk")
                                .font(.title3.bold())
                                .foregroundColor(.pink)
                            
                            Text("Avg: \(Int(avgStepCount))")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.bottom, 12)
                .foregroundStyle(.secondary)
                
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no step count data from the Health App")
                } else {
                    Chart {
                        if let selectedHealthMetric {
                            RuleMark(x: .value("Selected metric", selectedHealthMetric.date, unit: .day))
                                .foregroundStyle(.secondary.opacity(0.3))
                                .offset(y: -10)
                                .annotation(
                                    position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                        }
                        RuleMark(y: .value("Average", avgStepCount))
                            .foregroundStyle(.secondary)
                            .lineStyle(.init(lineWidth: 1, dash: [5]))
                        
                        ForEach(chartData) { steps in
                            BarMark(
                                x: .value("Date", steps.date, unit: .day),
                                y: .value("Steps",steps.value)
                            )
                            .foregroundStyle(Color.pink.gradient)
                            .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1 : 0.3)
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
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now,
                 format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.init(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    StepBarChart(selectedStat: .steps, chartData: MockData.steps)
}
