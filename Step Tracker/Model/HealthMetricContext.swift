//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
    
    var id: Self { self }
}
