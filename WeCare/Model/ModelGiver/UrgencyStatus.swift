//
//  UrgencyStatus.swift
//  WeCare
//
//  Created by student on 20/11/25.
//

import Foundation

enum UrgencyStatus: String, Codable, CaseIterable {
    case low, medium, high, critical, none
}
