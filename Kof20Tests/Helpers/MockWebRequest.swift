//
//  MockWebRequest.swift
//  Kof20Tests
//
//  Created by Ishmael King on 3/22/21.
//

import XCTest
@testable import Kof20

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    func resume() { }
}

class MockWebRequest: WebRequest {
    var nextDataTask = MockURLSessionDataTask()
    private (set) var lastURL: String?
    private (set) var lastMethod: String?
    private (set) var lastHeaders: [(value: String, key: String)]?
    private (set) var lastBody: Data?
    var dataResponseDic: Dictionary<String, Data>?
    var errorResponseDic: Dictionary<String, Error>?

    override func send(url: String, method: String, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = url
        lastMethod = method
        lastHeaders = headers
        lastBody = data

        let returnData = dataResponseDic?[url]
        let returnError = errorResponseDic?[url]
        
        if (returnData != nil) {
            handler(.success(returnData!))
        } else if (returnError != nil) {
            handler(.failure(returnError!))
        } else {
            print("Unhandled URL: \(url)")
        }
        
        return nextDataTask
    }
}
