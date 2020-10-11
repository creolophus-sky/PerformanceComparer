//
//  APIRequest.swift
//  StockPerformanceComparer
//
//  Created by Vadym Patalakh on 10.10.2020.
//

import Alamofire
import SwiftyJSON

typealias DataCompletion = (JSON) -> Void
typealias ErrorCompletion = (APIError) -> Void

protocol DisplayableError: Error {
  var title: String { get }
  var message: String { get }
}

struct APIError: DisplayableError {
    // MARK: Public Static Properties
    static let defaultErrorTitle = "Error."
    static let defaultErrorDescription = "Something went wrong, please try again."

    // MARK: DisplayableError Properties
    let title: String
    let message: String

    // MARK: Initializers
    init() {
        self.title = APIError.defaultErrorTitle
        self.message = APIError.defaultErrorDescription
    }

    init(title: String) {
        self.title = title
        self.message = APIError.defaultErrorDescription
    }

    init(message: String) {
        self.title = APIError.defaultErrorTitle
        self.message = message
    }

    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}

class APIRequest {
    // MARK: Private Properties
    private let session = Session()

    // MARK: Public Methods
    func get(url: String, parameters: Parameters? = nil, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
        request(url: url, method: .get, parameters: parameters, headers: nil, success: success, failure: failure)
    }

    // MARK: Private Methods
    private func request(url: String, method: HTTPMethod, parameters: Parameters?, encoding: ParameterEncoding = JSONEncoding.default, headers: HTTPHeaders?, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
        guard let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return failure(APIError(title: "URL was not valid.", message: APIError.defaultErrorDescription))
        }

        session.request(urlString, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().response { response in
            self.handle(response: response, success: success, failure: failure)
        }
    }

    private func handle(response: AFDataResponse<Data?>, success: @escaping DataCompletion, failure: @escaping ErrorCompletion) {
        let json: JSON

        if let error = response.error {
            return failure(APIError(message: error.localizedDescription))
        }

        guard let data = response.data else { return failure(APIError(message: "These is no data."))}

        do {
            json = try JSON(data: data)
        } catch {
            return failure(APIError(message: "Could not parse json."))
        }

        success(json["content"])
    }
}

