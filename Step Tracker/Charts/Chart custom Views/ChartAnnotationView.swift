//
//  ChartAnnotationView.swift
//  Step Tracker
//
//  Created by Neto Lobo on 09/07/24.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    let data: DateValueChartData
    let chartType: ChartType
    
    var fractionLenght: Int {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
            return 0
        case .exerciseBar(_):
            return 0
        case .weightLine(_):
            return 1
        case .weightDiffBar:
            return 1
        case .standBar(_):
            return 0
        }
    }
    
    var defaultColor: any ShapeStyle {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
            return .stepsColor
        case .exerciseBar(_):
            return .exerciseColor
        case .weightLine(_):
            return .weightColor
        case .weightDiffBar:
            return data.value >= 0 ? .positiveWeightColor : .negativeWeightColor
        case .standBar(_):
            return .standColor
        }
    }
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected metric", data.date, unit: .day))
            .foregroundStyle(.secondary.opacity(0.3))
            .offset(y: -10)
            .annotation(
                position: .top,
                spacing: 0,
                overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(data.date,
                 format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(data.value, format: .number.precision(.fractionLength(fractionLenght)))
                .fontWeight(.heavy)
                .foregroundStyle(defaultColor)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.init(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
    }
}

