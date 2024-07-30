//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Neto Lobo on 09/07/24.
//

import Foundation
import Algorithms

struct ChartHelper {
    
    /// Convert HealthMetric array to DateValueChartData array
    /// - Parameter data: Array of ``HealthMetric``
    /// - Returns: Array of ``DateValueChartData``
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value)}
    }
    
    
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    static func averageWeekDayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedbyWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedbyWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekDayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            
            weekDayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        return weekDayChartData
    }
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData]{
        var diffValues: [(date: Date, value: Double)] = []
        
        guard weights.count > 1 else { return [] }
        
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedbyWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedbyWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        
        var weekDayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeighDiff = total/Double(array.count)
            
            weekDayChartData.append(.init(date: firstValue.date, value: avgWeighDiff))
        }
        
        return weekDayChartData
    }
}
