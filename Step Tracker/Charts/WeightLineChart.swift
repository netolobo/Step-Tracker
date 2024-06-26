//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 26/06/24.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    var selectedStat: HealthMetricContext
    var chartdata: [HealthMetric]
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
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartdata: MockData.weights)
}
