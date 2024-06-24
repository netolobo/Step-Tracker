//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Neto Lobo on 24/06/24.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
