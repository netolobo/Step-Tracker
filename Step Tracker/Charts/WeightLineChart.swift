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
    var selectedStat: HealthMetricContext
    var chartdata: [HealthMetric]
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartdata.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var minValue: Double {
        chartdata.map{ $0.value }.min() ?? 0 //get the mininum value of the array
    }
    
    var body: some View {
        VStack {
            VStack {
                NavigationLink(value: selectedStat) {
                    HStack {
                        VStack(alignment: .leading) {
                            Label("Weight", systemImage: "figure")
                                .font(.title3.bold())
                                .foregroundColor(.indigo)
                            
                            Text("Avg: 180 lbs")
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.bottom, 12)
                .foregroundStyle(.secondary)
                
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
                    ForEach(chartdata) { weight in
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
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
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
    WeightLineChart(selectedStat: .weight, chartdata: MockData.weights)
}
