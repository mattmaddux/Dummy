//
//  API.swift
//
//  Created by Matt Maddux on 4/8/19.
//

import Foundation

class API {
    
    // ======================================================= //
    // MARK: - Sub Types
    // ======================================================= //
    
    enum Method: String {
        case get = "GET"
        case put = "PUT"
        case post = "POST"
        case patch = "PATCH"
        case delete = "DELETE"
        
    }
    
    struct APIResponse {
        var statusCode: HTTPStatusCode?
        var headers: URLResponse?
        var bodyData: Data?
        var bodyString: String? {
            guard let bodyData = bodyData else {
                return nil
            }
            return String(data: bodyData, encoding: .utf8)
        }
        var errorReason: String?
        var error: Error?
    }
    
    struct ErrorBody: Codable {
        var error: Bool
        var reason: String
    }
    
    // ======================================================= //
    // MARK: - Private Properties
    // ======================================================= //
    
    private var session = URLSession.shared
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    
    // ======================================================= //
    // MARK: - Initializer
    // ======================================================= //
    
    init() {
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601Full)
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
    }
    
    // ======================================================= //
    // MARK: - Methods
    // ======================================================= //
    
    func get<ResponseBody: Codable>(atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String: String] = [String:String](), responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        try self.makeRequest(ofType: API.Method.get, atURL: url, withQueries: queries, andHeaders: headers, andBody: nil as ResponseBody?, responseType: responseType, completion: completion)
    }
    
    func put<RequestBody: Codable, ResponseBody:Codable>(atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String: String] = [String:String](), andBody body: RequestBody?, responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        try self.makeRequest(ofType: API.Method.put, atURL: url, withQueries: queries, andHeaders: headers, andBody: body, responseType: responseType, completion: completion)
    }
    
    func post<RequestBody: Codable, ResponseBody:Codable>(atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String: String] = [String:String](), andBody body: RequestBody?, responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        try self.makeRequest(ofType: API.Method.post, atURL: url, withQueries: queries, andHeaders: headers, andBody: body, responseType: responseType, completion: completion)
    }
    
    func patch<RequestBody: Codable, ResponseBody:Codable>(atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String: String] = [String:String](), andBody body: RequestBody?, responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        try self.makeRequest(ofType: API.Method.patch, atURL: url, withQueries: queries, andHeaders: headers, andBody: body, responseType: responseType, completion: completion)
    }
    
    func delete<ResponseBody: Codable>(atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String: String] = [String:String](), responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        try self.makeRequest(ofType: API.Method.delete, atURL: url, withQueries: queries, andHeaders: headers, andBody: nil as ResponseBody?, responseType: responseType, completion: completion)
    }
    
    func makeRequest<RequestBody: Codable, ResponseBody: Codable>(ofType method: Method, atURL url: URL, withQueries queries: [String: String] = [String:String](), andHeaders headers: [String:String]?, andBody body: RequestBody?, responseType: ResponseBody.Type, completion: @escaping (ResponseBody?, APIResponse) -> Void ) throws {
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = url.path
        if queries.count > 0 {
            components.queryItems = queries.map() { URLQueryItem(name: $0, value: $1) }
        }
        
        // Create & Configure Request
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpShouldHandleCookies = false
        request.allowsCellularAccess = true
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        // Create Data Task w/ Request & Completion Handler
        let task = session.dataTask(with: request) { (responseData, response, error) in
            // Get parts of APIResponse from URLResponse & raw data
            let statusCode: HTTPStatusCode?
            if let response = response as? HTTPURLResponse {
                statusCode = HTTPStatusCode(rawValue: response.statusCode)
            } else {
                statusCode = nil
            }
            
            var decodedResponse: ResponseBody? = nil
            var errorReason: String? = nil
            if let responseData = responseData {
                // Decode Requested Type from Body
                do {
                    decodedResponse = try self.decoder.decode(ResponseBody.self, from: responseData)
                } catch {
                    print(error)
                }
                
                // Decode Error Body (if Applicable)
                if let decodedErrorBody = try? self.decoder.decode(ErrorBody.self, from: responseData) {
                    errorReason = decodedErrorBody.reason.trimmingCharacters(in: .punctuationCharacters)
                }
            }
            
            // Build response
            let apiResponse = APIResponse(statusCode: statusCode, headers: response, bodyData: responseData, errorReason: errorReason, error: error)
            
            // Pass decoded object and response to completion handler
            completion(decodedResponse, apiResponse)
        }
        
        // Initiate Request
        task.resume()
    }
    
    // ======================================================= //
    // MARK: - Private Methods
    // ======================================================= //
    
    private func descriptionOf(request: URLRequest?) -> String {
       var result = "----------REQUEST----------\n"
       result += "HEADERS:\n"
       if let request = request {
           result += "\(request)\n"
       } else {
           result += "NONE\n"
       }
       result += "--------END REQUEST--------"
       return result
   }
    
    private func descriptionOf(response: URLResponse?, andBody body: Data?) -> String {
        var result = "----------RESPONSE----------\n"
        result += "HEADERS:\n"
        if let response = response {
            result += "\(response)\n"
        } else {
            result += "NONE\n"
        }
        result += "BODY:\n"
        if let body = body {
            if let bodyString = String(data: body, encoding: .utf8) {
                result += "\(bodyString)\n"
            } else {
                result += "Can't convert body data to String\n"
            }
        } else {
            result += "NONE\n"
        }
        result += "--------END RESPONSE--------"
        return result
    }
    
    
    
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
}

enum HTTPStatusCode: Int {
    case cont = 100
    case switchingProtocols = 101
    case processing = 102
    case ok = 200
    case created = 201
    case accepted = 202
    case nonAuthoritativeInformation = 203
    case noContent = 204
    case resetContent = 205
    case partialContent = 206
    case multiStatus = 207
    case alreadyReported = 208
    case imUsed = 226
    case multipleChoices = 300
    case movedPermanently = 301
    case found = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case temporaryRedirect = 307
    case permanentRedirect = 308
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case proxyAuthenticationRequired = 407
    case requestTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconditionFailed = 412
    case payloadTooLarge = 413
    case requestURITooLong = 414
    case unsupportedMediaType = 415
    case requestedRangeNotSatisfiable = 416
    case expectationFailed = 417
    case imATeapot = 418
    case misdirectedRequest = 421
    case unprocessableEntity = 422
    case locked = 423
    case failedDependency = 424
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests = 429
    case requestHeaderFieldsTooLarge = 431
    case connectionClosedWithoutResponse = 444
    case unavailableForLegalReasons = 451
    case clientClosedRequest = 499
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
    case gatewayTimeout = 504
    case httpVersionNotSupported = 505
    case variantAlsoNegotiates = 506
    case insufficientStorage = 507
    case loopDetected = 508
    case notExtended = 510
    case networkAuthenticationRequired = 511
    case networkConnectTimeoutError = 599
}
