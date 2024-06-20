//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Neto Lobo on 20/06/24.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    let store = HKHealthStore()
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
