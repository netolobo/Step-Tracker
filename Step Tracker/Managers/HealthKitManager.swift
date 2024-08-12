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
    let shareTypes: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    let readTypes: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass), HKQuantityType(.appleMoveTime), HKQuantityType(.appleStandTime), HKQuantityType(.appleExerciseTime)]
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    var moveData: [HealthMetric] = []
    var standData: [HealthMetric] = []
    var exerciseData: [HealthMetric] = []
    
    /// Fetch last 7 days of activity time from HealthKit.
    /// - Parameter activity: Ex - .appleMoveTime
    /// - Returns: Array of ``HealthMetric``
    func fetchActivityTimeCount(_ activity: HKQuantityTypeIdentifier, _ unit: HKUnit) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(activity)) != .notDetermined else {
            throw STError.authNotDetermined
        }

        let interval = createDateInterval(from: .now, daysBack: 7)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(activity), predicate: queryPredicate)
        
        let activityTimeQuery = HKStatisticsCollectionQueryDescriptor(
                                                                predicate: samplePredicate,
                                                                options: .cumulativeSum,
                                                                anchorDate: interval.end,
                                                                intervalComponents: .init(day: 1))
        
        do {
            let activityTimeCounts = try await activityTimeQuery.result(for: store)
            
            
            print("✅ print is working")
            
            for activitityTime in activityTimeCounts.statistics() {
                switch activity {
                case .appleMoveTime:
                    print("♥️ = \(activitityTime.sumQuantity()?.doubleValue(for: unit) ?? 0.1)")
                case .appleStandTime:
                    print("🩵 = \(activitityTime.sumQuantity()?.doubleValue(for: unit) ?? 0.2)")
                case .appleExerciseTime:
                    print("💚 = \(activitityTime.sumQuantity()?.doubleValue(for: unit) ?? 0.3)")
                default:
                    break
                }
                
            }
            
            return activityTimeCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unbableToCompleteRequest
        }
    }
    
    /// Fetch last 28 days steps count from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchStepsCount() async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }

        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
                                                                predicate: samplePredicate,
                                                                options: .cumulativeSum,
                                                                anchorDate: interval.end,
                                                                intervalComponents: .init(day: 1))
        
        do {
            let stepCounts = try await stepsQuery.result(for: store)
            
            return stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unbableToCompleteRequest
        }
    }
    
    /// Fetch most recent weight sample on each day for a specified number of days back from today.
    /// - Parameter daysBack: Days back from today. Ex - 28 will return the last 28 days.
    /// - Returns: Array of ``HealthMetric``
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: interval.end,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try await weightsQuery.result(for: store)
            return weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unbableToCompleteRequest
        }
    }
    
    
    /// Write step count data to HealthKit. Requires HealthKit write permission.
    /// - Parameters:
    ///   - date: Date for step count value
    ///   - value: Step count value
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(HKQuantityType: "step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unbableToCompleteRequest
        }
    }
    
    /// Write weight value to HealthKit. Requires HealthKit write permisson.
    /// - Parameters:
    ///   - date: Date for weight value
    ///   - value: Weight value in pounds. Uses pounds as Double for .bodyMass conversions.
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharingDenied(HKQuantityType: "weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let weightQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unbableToCompleteRequest
        }
    }
    
    /// Creates a DateInterval between two dates
    /// - Parameters:
    ///   - date: End of date interval. Ex - today
    ///   - daysBack: Start of date interval. Ex - 28 days ago
    /// - Returns: Date range between two dates as a DateInterval
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!
        return .init(start: startDate, end: endDate)
    }
    
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//        
//        for i in 0..<28 {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
//            
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
//            
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//        }
//        
//        try! await store.save(mockSamples)
//        
//        print("Dummy Data sent up ✅")
//    }
}
