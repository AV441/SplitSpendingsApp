//
//  Date extension.swift
//  SplitSpendings
//
//  Created by Андрей on 06.10.2022.
//

import Foundation

extension Date {
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    var formatted: String {
        return Date.formatter.string(from: self)
    }
    
    var onlyDate: Date {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents) ?? Date()
        }
    }
}
