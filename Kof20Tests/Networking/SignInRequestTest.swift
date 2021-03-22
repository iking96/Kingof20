//
//  SignInRequestTest.swift
//  Kof20Tests
//
//  Created by Ishmael King on 3/8/21.
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
    var returnData: Data?
    var returnError: Error?

    override func send(url: String, method: String, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = url
        lastMethod = method
        lastHeaders = headers
        lastBody = data
        lastBody = data

        if (returnData != nil) {
            handler(.success(returnData!))
        } else if (returnError != nil) {
            handler(.failure(returnError!))
        }
        
        return nextDataTask
    }
}

class SignInRequestTests: XCTestCase {
    var signInRequest: SignInRequest!
    let webRequest = MockWebRequest()
    
    override func setUp() {
        super.setUp()
        signInRequest = SignInRequest(webRequest: webRequest)
    }

    func test_basic_sign_in() {
        signInRequest.signIn(username: "john", password: "doe") { _ in }
        XCTAssert(webRequest.lastURL == "https://kingof20.com/oauth/token?username=john&password=doe&grant_type=password")
        XCTAssert(webRequest.lastMethod == "POST")
    }
    
    func test_sucessful_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(SignInResponse(accessToken: "1234"))
        
        webRequest.returnData = data
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .success(SignInResponse(accessToken: "1234")))
        }
    }

    func test_not_found_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(["status_code": "401"])
        
        webRequest.returnData = data
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.notFound))
        }
    }
    
    func test_unexpected_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(["status_code": "301"])
        
        webRequest.returnData = data
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.unexpectedResponse))
        }
    }
    
    func test_error_response() {
        webRequest.returnError = NSError()
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.requestFailed))
        }
    }
}
