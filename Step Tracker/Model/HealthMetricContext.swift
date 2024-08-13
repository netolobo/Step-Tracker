//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight, activity
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        case .activity:
            return "Activity"
        }
    }
    
    var id: Self { self }
}
