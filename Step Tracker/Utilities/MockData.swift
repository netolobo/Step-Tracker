//
//  MockData.swift
//  Step Tracker
//
//  Created by Neto Lobo on 26/06/24.
//

import Foundation

struct MockData {
    static var stand: [DateValueChartData] {
        var array: [HealthMetric] = []
        
        for i in 0..<7 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 1...20))
            array.append(metric)
        }
        
        return array.map { .init(date: $0.date, value: $0.value) }
    }
    
    static var exercise: [DateValueChartData] {
        var array: [HealthMetric] = []
        
        for i in 0..<7 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 30...180))
            array.append(metric)
        }
        
        return array.map { .init(date: $0.date, value: $0.value) }
    }
    
    static var steps: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 4_000...15_000))
            array.append(metric)
        }
        
        return array
    }
    
    static var weights: [HealthMetric] {
        var array: [HealthMetric] = []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: (88 + Double(i/3)...95 + Double(i/3))))
            array.append(metric)
        }
        
        return array
    }
    
    static var weightsDiffs: [DateValueChartData] {
        var array: [DateValueChartData] = []
        
        for i in 0..<7 {
            let diff = DateValueChartData(
                date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                value: .random(in: -3...3)
            )
            
            array.append(diff)
        }
        
        return array
    }
}
