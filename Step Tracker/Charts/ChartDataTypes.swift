//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation

struct WeekDayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
