//
//  ResponseParser.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import SwiftyJSON

class ResponseParser {
    // MARK: Private Types
    private struct StocksJSONKeys {
        static let name = "symbol"
        static let timestamps = "timestamps"
        static let opens = "opens"
        static let closures = "closures"
        static let highs = "highs"
        static let lows = "lows"
        static let volumes = "volumes"
    }

    // MARK: Public Methods
    func parseStocks(json: [JSON]) -> [Stock] {
        var stocks = [Stock]()

        for stockJson in json {
            let name = stockJson[StocksJSONKeys.name].stringValue
            let stock = Stock(name: name, prices: parseStockPrice(json: stockJson))
            stocks.append(stock)
        }

        return stocks
    }

    // MARK: Private Methods
    private func parseStockPrice(json: JSON) -> [StockPrice] {
        var stockPrices = [StockPrice]()
        let timestamps = json[StocksJSONKeys.timestamps].arrayValue
        let opens = json[StocksJSONKeys.opens].arrayValue
        let closures = json[StocksJSONKeys.closures].arrayValue
        let highs = json[StocksJSONKeys.highs].arrayValue
        let lows = json[StocksJSONKeys.lows].arrayValue
        let volumes = json[StocksJSONKeys.volumes].arrayValue

        for (index, timestamp) in timestamps.enumerated() {
            let stockPrice = StockPrice(timestamp: timestamp.doubleValue,
                                        open: opens[index].doubleValue,
                                        close: closures[index].doubleValue,
                                        high: highs[index].doubleValue,
                                        low: lows[index].doubleValue,
                                        volumes: volumes[index].int64Value)
            stockPrices.append(stockPrice)
        }

        return stockPrices
    }
}
