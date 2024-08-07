//
//  Color+Ext.swift
//  Step Tracker
//
//  Created by Neto Lobo on 07/08/24.
//

import Foundation
import SwiftUI

extension ShapeStyle where Self == Color {
    static var stepsColor : Color { .green }
    static var weightColor: Color { .orange }
    static var goalColor: Color { .blue }
    static var positiveWeightColor: Color { .pink }
    static var negativeWeightColor: Color { .mint }
}
