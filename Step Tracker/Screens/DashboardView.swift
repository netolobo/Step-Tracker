//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Neto Lobo on 17/06/24.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: STError = .noData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: ChartHelper.convert(data: hkManager.stepData))
                        
                        StepPieChart(chartData: ChartHelper.averageWeekDayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkManager.weightData))
                        
                        WeightDiffBarChart(chartData: ChartHelper.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPrimingSheet) {
                fetchHealthData()
            } content: {
                HealthKitPremissionPrimingView()
            }
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(selectedStat == .steps ? .pink : .indigo)
    }
    
    private func fetchHealthData() {
        Task {
            do {
                async let steps = hkManager.fetchStepsCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                
                hkManager.stepData = try await steps
                hkManager.stepData = try await weightsForLineChart
                hkManager.stepData = try await weightsForDiffBarChart
            } catch STError.authNotDetermined{
                isShowingPermissionPrimingSheet = true
            } catch STError.noData {
                fetchError = .noData
                isShowingAlert = true
            } catch {
                fetchError = .unbableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
