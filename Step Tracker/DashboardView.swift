//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Neto Lobo on 17/06/24.
//

import SwiftUI
import Charts

enum HelthMetricContext: CaseIterable, Identifiable {
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

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HelthMetricContext = .steps
    private var isSteps: Bool { selectedStat == .steps }
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else { return 0}
        let totalSteps = hkManager.stepData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(hkManager.stepData.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected stat", selection: $selectedStat) {
                        ForEach(HelthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack {
                        VStack {
                            NavigationLink(value: selectedStat) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Label("Steps", systemImage: "figure.walk")
                                            .font(.title3.bold())
                                            .foregroundColor(.pink)
                                        
                                        Text("Avg: \(Int(avgStepCount))")
                                            .font(.caption)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .padding(.bottom, 12)
                            .foregroundStyle(.secondary)
                            
                            Chart {
                                RuleMark(y: .value("Average", avgStepCount))
                                    .foregroundStyle(.secondary)
                                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                                
                                ForEach(hkManager.stepData) { steps in
                                    BarMark(
                                        x: .value("Date", steps.date, unit: .day),
                                        y: .value("Steps",steps.value)
                                    )
                                    .foregroundStyle(Color.pink.gradient)
                                }
                            }
                            .frame(height: 150)
                            .chartXAxis {
                                AxisMarks {
                                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisGridLine()
                                        .foregroundStyle(.secondary.opacity(0.3))
                                    
                                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    VStack {
                        VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    Label("Averages", systemImage: "calendar")
                                        .font(.title3.bold())
                                        .foregroundColor(.pink)
                                    
                                    Text("Last 28 Days")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            .padding(.bottom, 12)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.secondary)
                                .frame(height: 240)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
            }
            .padding()
            .task {
                await hkManager.fetchStepsCount()
                isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HelthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPrimingSheet) {
                //fetch health data
            } content: {
                HealthKitPremissionPrimingView(hasSeen: $hasSeenPermissionPriming)
            }
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
