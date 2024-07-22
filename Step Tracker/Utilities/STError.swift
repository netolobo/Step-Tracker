//
//  STError.swift
//  Step Tracker
//
//  Created by Neto Lobo on 11/07/24.
//

import Foundation
import HealthKit
import Observation

enum STError: Error, LocalizedError {
    case authNotDetermined
    case sharingDenied(HKQuantityType: String)
    case noData
    case unbableToCompleteRequest
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Need Acess to Health Data"
        case .sharingDenied(_):
            "No Write Acess"
        case .noData:
            "No Data"
        case .unbableToCompleteRequest:
            "Unable to Complete Request"
        case .invalidValue:
            "Invalid Value"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not given acess to your Health data. Please go to Settings > Health > Data Access & Devices."
        case .sharingDenied(let quantityType):
            "You have denied acess to upload your \(quantityType) data. \n\nYou can change this in Settings > Health > Data Access & Devices."
        case .noData:
            "There is no data for this Health statistic"
        case .unbableToCompleteRequest:
            "We are unable to comple your requeste at this time.\n\nPlease try again later or contact support."
        case .invalidValue:
            "Must be a numeric value with a maximum of one decimal place."
        }
    }
}
