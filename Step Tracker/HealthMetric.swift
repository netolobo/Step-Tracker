//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Neto Lobo on 20/06/24.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
