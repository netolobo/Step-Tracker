//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Neto Lobo on 08/07/24.
//

import SwiftUI

enum ChartType : Equatable {
    case standBar(average: Int)
    case exerciseBar(average: Int)
    case stepBar(average: Int)
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
        .accessibilityHint("Tap for data in list view")
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundColor(defaultColor as? Color)
            
            Text(subtitle)
                .font(.caption)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityElement(children: .ignore)
    }
    
    var isNav: Bool {
        switch chartType {
        case .stepBar(_), .weightLine(_):
            return true
        case .stepWeekdayPie, .weightDiffBar, .standBar(_), .exerciseBar(_):
            return false
        }
    }
    
    var context: HealthMetricContext {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
                .steps
        case .weightLine(_), .weightDiffBar:
                .weight
        case .standBar(_), .exerciseBar(_):
                .activity
        }
    }
    
    var defaultColor: any ShapeStyle {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
            return .stepsColor
        case .exerciseBar(_):
            return .exerciseColor
        case .weightLine(_), .weightDiffBar:
            return .weightColor
        case .standBar(_):
            return .standColor
        }
    }
    
    var title: String {
        switch chartType {
        case .stepBar(_):
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine(_):
            "Weight"
        case .weightDiffBar:
            "Average Weight Change"
        case .standBar(_):
            "Stand"
        case .exerciseBar(_):
            "Exercise"
        }
    }
    
    var symbol: String {
        switch chartType {
        case .stepBar(_):
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine(_), .weightDiffBar:
            "figure"
        case .standBar(_):
            "figure.wave"
        case .exerciseBar(_):
            "figure.run"
        }
    }
    
    var subtitle: String {
        switch chartType {
        case .stepBar(let average):
            "Avg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 days"
        case .weightLine( let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        case .standBar(let average):
            "Last 7 days avg: \(average) hours"
        case .exerciseBar(let average):
            "Last 7 days avg: \(average) minutes"
        }
    }
    
    var accessibilityLabel: String {
        switch chartType {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average) steps"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine( let average):
            "Line chart, weight, average weight \(average.formatted(.number.precision(.fractionLength(1)))) pounds, goal weight: 155 pounds"
        case .weightDiffBar:
            "Bar chart, average weight difference per weekday"
        case .standBar(average: let average):
            "Bar chart, stand hours, last 7 days, average stand time per day: \(average) hours"
        case .exerciseBar(average: let average):
            "Bar chart, exercise time, last 7 days, average exercuse time per day: \(average) minutes"
        }
    }
}

#Preview {
    ChartContainer(chartType: .exerciseBar(average: 32)) {
        Text ("Chart goes here")
    }
}
