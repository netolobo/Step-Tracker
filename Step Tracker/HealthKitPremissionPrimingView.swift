//
//  HealthKitPremissionPrimingView.swift
//  Step Tracker
//
//  Created by Neto Lobo on 19/06/24.
//

import SwiftUI

struct HealthKitPremissionPrimingView: View {
    var description = """
    This app displays your step and wight data in interactive charts.

    You can also add new step or weight data to Apple Health from this app. Your data is private and secured.
    """
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(.appleHealth)
                .resizable()
                .frame(width: 90, height: 90)
                .shadow(color: .gray.opacity(0.3), radius: 16)
                .padding(.bottom, 12)
            
            Text("Apple Health Integration")
            
            Text(description)
                .foregroundStyle(.secondary)
            
            Button("Connect Apple Health") {
                //do code later
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
        }
        .padding(30)
    }
}

#Preview {
    HealthKitPremissionPrimingView()
}
