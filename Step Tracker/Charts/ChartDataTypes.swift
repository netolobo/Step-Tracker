//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
