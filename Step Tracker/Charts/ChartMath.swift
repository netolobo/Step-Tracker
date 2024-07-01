//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation
import Algorithms

struct ChartMath {
    static func averageWeekDayCount(for metric: [HealthMetric]) -> [WeekDayChartData] {
        let sortedbyWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedbyWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekDayChartData: [WeekDayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekDayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        return weekDayChartData
    }
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [WeekDayChartData]{
        var diffValues: [(date: Date, value: Double)] = []
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedbyWeekday = diffValues.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedbyWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekDayChartData: [WeekDayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeighDiff = total/Double(array.count)
            
            weekDayChartData.append(.init(date: firstValue.date, value: avgWeighDiff))
        }
        
        return weekDayChartData
    }
}
