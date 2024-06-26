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
                            y: .value("Value", weight.value)
                        )
                        .foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))
                        
                        LineMark(
                            x: .value("Day", weight.date, unit: .day),
                            y: .value("Value", weight.value)
                        )
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartdata: MockData.weights)
}
