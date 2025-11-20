//
//  DateUtils.swift
//  WeCare
//
//  Created by student on 20/11/25.
//

import Foundation

func dateKey(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: date)
}

func dateKey(forDay day: Int, in baseDate: Date) -> String {
    var components = Calendar.current.dateComponents([.year, .month], from: baseDate)
    components.day = day
    let date = Calendar.current.date(from: components) ?? baseDate
    return dateKey(from: date)
}
