//
//  Stock.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import Foundation

protocol PerformanceValuable {
    func getPerformanceValue(with endingPrice: Double) -> Double
    func calculatePerformanceValue(start: Double, end: Double) -> Double
}

extension PerformanceValuable {
    func calculatePerformanceValue(start: Double, end: Double) -> Double {
        let value = (end - start) / start * 100
        return Double(round(100 * value) / 100)
    }
}

class Stock: PerformanceValuable {
    // MARK: Public Types
    struct PerformanceData {
        let timestamp: Double
        let data: Double
    }

    // MARK: Public Properties
    let name: String
    let prices: [StockPrice]
    private(set) var performanceData: [PerformanceData] = []

    // MARK: Public Methods
    init(name: String, prices: [StockPrice]) {
        self.name = name
        self.prices = prices
        calculatePerformanceData()
    }

    // MARK: Private Methods
    private func calculatePerformanceData() {
        guard let startingPrice = prices.first?.close else { return }

        for (index, price) in prices.enumerated() {
            if index == 0 {
                performanceData.append(PerformanceData(timestamp: price.timestamp, data: 0))
                continue
            }

            let data = calculatePerformanceValue(start: startingPrice, end: price.close)

            performanceData.append(PerformanceData(timestamp: price.timestamp, data: data))
        }
    }

    // MARK: PerformanceValuable Methods
    func getPerformanceValue(with endingPrice: Double) -> Double {
        guard let startingPrice = prices.first?.close else { return 0 }

        return calculatePerformanceValue(start: startingPrice, end: endingPrice)
    }
}
