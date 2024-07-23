//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Neto Lobo on 08/07/24.
//

import SwiftUI

enum ChartType {
    case setepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainer<Content: View>: View {
    let chartType: ChartType
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if isNav {
                    navigationLinkView
                } else {
                    titleView
                        .padding(.bottom, 12)
                        .foregroundStyle(.secondary)
                }
                
                content()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        }
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .padding(.bottom, 12)
        .foregroundStyle(.secondary)
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundColor(context == .steps ? .pink : .indigo)
            
            Text(subtitle)
                .font(.caption)
        }
    }
    
    var isNav: Bool {
        switch chartType {
        case .setepBar(_), .weightLine(_):
            return true
        case .stepWeekdayPie, .weightDiffBar:
            return false
        }
    }
    
    var context: HealthMetricContext {
        switch chartType {
        case .setepBar(_), .stepWeekdayPie:
                .steps
        case .weightLine(_), .weightDiffBar:
                .weight
        }
    }
    
    var title: String {
        switch chartType {
        case .setepBar(_):
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine(_):
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        }
    }
    
    var symbol: String {
        switch chartType {
        case .setepBar(_):
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine(_), .weightDiffBar:
            "figure"
        }
    }
    
    var subtitle: String {
        switch chartType {
        case .setepBar(let average):
            "AVg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 days"
        case .weightLine( let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        }
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie) {
        Text ("Chart goes here")
    }
}
