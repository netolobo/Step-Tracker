//
//  HealthKitPremissionPrimingView.swift
//  Step Tracker
//
//  Created by Neto Lobo on 19/06/24.
//

import SwiftUI
import HealthKitUI

struct HealthKitPremissionPrimingView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingHealthKitPermission = false
    @Environment(\.dismiss) private var dismiss
    
    var description = """
    This app displays your step and weight data in interactive charts.
    
    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 10) {
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Apple Health Integration")
                
                Text(description)
                    .foregroundStyle(.secondary)
                
            }
            Button("Connect Apple Health") {
                isShowingHealthKitPermission = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
        .interactiveDismissDisabled()
        .healthDataAccessRequest(
            store: hkManager.store,
            shareTypes: hkManager.types,
            readTypes: hkManager.types,
            trigger: isShowingHealthKitPermission) { result in
                switch result {
                case .success(_):
                    dismiss()
                case .failure(_):
                    //handle the error later
                    dismiss()
                }
            }
    }
}

#Preview {
    HealthKitPremissionPrimingView()
        .environment(HealthKitManager())
}
