//
//  DateExtension.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import Foundation

extension Date {
    func toRepresantableString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        return dateFormatter.string(from: self)
    }
}
