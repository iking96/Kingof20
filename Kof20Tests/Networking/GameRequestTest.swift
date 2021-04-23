//
//  SignInRequestTest.swift
//  Kof20Tests
//
//  Created by Ishmael King on 3/8/21.
//

import XCTest
@testable import Kof20

class GameRequestTests: XCTestCase {
    var gameRequest: GameRequest!
    let webRequest = MockWebRequest()
    
    override func setUp() {
        super.setUp()
        gameRequest = GameRequest(webRequest: webRequest)
    }

    func test_index() {
        gameRequest.index(accessToken: "VALID_ACCESS_TOKEN") { _ in }
        XCTAssert(webRequest.lastURL == "http://localhost:3000/api/v1/games")
        XCTAssert(webRequest.lastMethod == "GET")
        XCTAssert(webRequest.lastHeaders != nil)
    }

    func test_sucessful_index_response() {
        let string = "{\"games\": [{\"id\":1234,\"other_data\":\"something else\"},{\"id\":5678,\"other_data\":\"something else\"}]}"
        let data = string.data(using: .utf8)!

        let callback_expectation = expectation(description: "GameRequest#index evalutes callback")

        webRequest.dataResponseDic = ["http://localhost:3000/api/v1/games" : data]
        gameRequest.index(accessToken: "VALID_ACCESS_TOKEN") { (result) in
            XCTAssert(result == .success([GameResponse(id: 1234), GameResponse(id: 5678)]))
            callback_expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
          if let error = error {
            XCTFail("waitForExpectationsWithTimeout errored: \(error)")
          }
        }
    }
    
    func test_index_failed_response() {
        webRequest.errorResponseDic = ["http://localhost:3000/api/v1/games" : NSError()]
        
        gameRequest.index(accessToken: "VALID_ACCESS_TOKEN") { (result) in
            XCTAssert(result == .failure(GameRequestError.requestFailed))
        }
    }
}
