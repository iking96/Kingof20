//
//  SignInRequestTest.swift
//  Kof20Tests
//
//  Created by Ishmael King on 3/8/21.
//

import XCTest
@testable import Kof20

class SignInRequestTests: XCTestCase {
    var signInRequest: SignInRequest!
    let webRequest = MockWebRequest()
    
    override func setUp() {
        super.setUp()
        signInRequest = SignInRequest(webRequest: webRequest)
    }

    func test_basic_sign_in() {
        signInRequest.signIn(username: "john", password: "doe") { _ in }
        XCTAssert(webRequest.lastURL == "http://localhost:3000/oauth/token?username=john&password=doe&grant_type=password")
        XCTAssert(webRequest.lastMethod == "POST")
    }
    
    func test_sucessful_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(SignInResponse(accessToken: "1234"))
        
        webRequest.dataResponseDic = ["http://localhost:3000/oauth/token?username=john&password=doe&grant_type=password" : data]
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .success(SignInResponse(accessToken: "1234")))
        }
    }

    func test_not_found_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(["status_code": 401])
        
        webRequest.dataResponseDic = ["http://localhost:3000/oauth/token?username=john&password=doe&grant_type=password" : data]
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.notFound))
        }
    }
    
    func test_unexpected_response() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(["status_code": 301])
        
        webRequest.dataResponseDic = ["http://localhost:3000/oauth/token?username=john&password=doe&grant_type=password" : data]
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.unexpectedResponse))
        }
    }
    
    func test_error_response() {
        webRequest.errorResponseDic = ["http://localhost:3000/oauth/token?username=john&password=doe&grant_type=password" : NSError()]
        
        signInRequest.signIn(username: "john", password: "doe") { (result) in
            XCTAssert(result == .failure(SignInRequestError.requestFailed))
        }
    }
}
