//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Neto Lobo on 08/07/24.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNave: Bool
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                if isNave {
                    navigationLinkView
                } else {
                    titleView
                        .padding(.bottom, 12)
                        .foregroundStyle(.secondary)
                }
                
                content()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        }
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
        .padding(.bottom, 12)
        .foregroundStyle(.secondary)
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundColor(context == .steps ? .pink : .indigo)
            
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(title: "Test title", symbol: "figure.walk", subtitle: "Test Subtitle", context: .steps, isNave: true, content: { Text ("Chart goes here")})
}
