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
    private var isSteps: Bool { selectedStat == .steps }

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
                        StepBarChart(selectedStat: selectedStat, chartdata: hkManager.stepData)
                        
                        StepPieChart(chartData: ChartMath.averageWeekDayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartdata: hkManager.weightData)
                        
                        WeightBarChart(chartdata: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task {
                do {
                    try await hkManager.fetchStepsCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsforDifferentials()
                } catch STError.authNotDetermined{
                    isShowingPermissionPrimingSheet = true
                } catch STError.noData {
                    print("❌ No Data Error")
                } catch {
                    print("❌ Unable to complete request")
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthKitPremissionPrimingView()
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
