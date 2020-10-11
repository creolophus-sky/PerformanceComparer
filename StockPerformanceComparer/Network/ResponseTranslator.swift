//
//  ResponseTranslator.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

class ResponseTranslator {
    // MARK: Private Properties
    private let parser = ResponseParser()

    // MARK: Public Methods
    func translate(response: @escaping StockCompletion) -> DataCompletion {
        return { apiResponse in
            response(self.parser.parseStocks(json: apiResponse["quoteSymbols"].array ?? []))
        }
    }
}
