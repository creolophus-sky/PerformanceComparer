//
//  StockPrice.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import Foundation
import SwiftyJSON

struct StockPrice {
    // MARK: Private types
    struct JSONKeys {
        let timestamp = "timestamps"
    }

    // MARK: Public Properties
    let timestamp: Double
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let volumes: Int64
}
