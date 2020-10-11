//
//  StockRequest.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

typealias StockCompletion = ([Stock]) -> Void

class StockRequest {
    // MARK: Private Properties
    private let baseURL = "https://www.dropbox.com/s/"
    private let request = APIRequest()
    private let translator = ResponseTranslator()

    // MARK: Public Methods
    func getWeeklyStock(success: @escaping StockCompletion, failure: @escaping ErrorCompletion) {
        request.get(url: baseURL + "fkmoo3pusjmeprm/responseQuotesWeek.json?dl=1",
                    success: translator.translate(response: success),
                    failure: failure)
    }

    func getMonthlyStock(success: @escaping StockCompletion, failure: @escaping ErrorCompletion) {
        request.get(url: baseURL + "ekimesctwgavnhq/responseQuotesMonth%20%281%29.json?dl=1",
                    success: translator.translate(response: success),
                    failure: failure)
    }
}
