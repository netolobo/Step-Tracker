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
    @State private var rawSelectedDate: Date?
    private var isSteps: Bool { selectedStat == .steps }
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else { return 0}
        let totalSteps = hkManager.stepData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(hkManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        
        return hkManager.stepData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
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
                                if let selectedHealthMetric {
                                    RuleMark(x: .value("Selected metric", selectedHealthMetric.date, unit: .day))
                                        .foregroundStyle(.secondary.opacity(0.3))
                                        .offset(y: -10)
                                        .annotation(
                                            position: .top,
                                            spacing: 0,
                                            overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                                }
                                RuleMark(y: .value("Average", avgStepCount))
                                    .foregroundStyle(.secondary)
                                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                                
                                ForEach(hkManager.stepData) { steps in
                                    BarMark(
                                        x: .value("Date", steps.date, unit: .day),
                                        y: .value("Steps",steps.value)
                                    )
                                    .foregroundStyle(Color.pink.gradient)
                                    .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1 : 0.3)
                                }
                            }
                            .frame(height: 150)
                            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
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
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now,
                 format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0)))
                .fontWeight(.heavy)
                .foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.init(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
