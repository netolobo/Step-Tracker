//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    var chartData: [WeekDayChart] = []
    
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
                
                Chart {
                    ForEach(chartData) { weekDay in
                        SectorMark(
                            angle: .value("Average Steps", weekDay.value),
                            innerRadius: .ratio(0.618),
                            angularInset: 1
                        )
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(6)
                    }
                }
                .chartLegend(.hidden)
                .frame(height: 240)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekDayCount(for: HealthMetric.mockData))
}
