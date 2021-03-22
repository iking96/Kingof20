//
//  SignInRequestHelper.swift
//  Kof20
//
//  Created by Ishmael King on 12/24/20.
//

import Foundation

enum SignInRequestError: Error, Equatable {
    case signInError
    case notFound
    case requestFailed
    case unexpectedResponse
}

protocol SignInRequestProtocol {
    func signIn(username: String,
                  password: String,
                  completion: @escaping (Result<SignInResponse, SignInRequestError>) -> Void)
}

struct SignInResponse : Codable, Equatable {
    var accessToken: String
}

class SignInRequest: SignInRequestProtocol {
    private let webRequest: WebRequestProtocol

    init(webRequest: WebRequestProtocol = WebRequest()) {
        self.webRequest = webRequest
    }
    
    func signIn(username: String,
                  password: String,
                  completion: @escaping (Result<SignInResponse, SignInRequestError>) -> Void) {
        let url = "\(APPURL.LoginURL)?username=\(username)&password=\(password)&grant_type=password"

        _ = webRequest.send(url: url, method: "POST"){ (result) in
            switch result {
            case .success(let jsonData):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                if let signInResponse = try? decoder.decode(SignInResponse.self, from: jsonData) {
                    completion(.success(signInResponse))
                    return
                } else if let error = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    // Parsing JSON to get error code
                    if let statusCode = error["status_code"] as? Int {
                        // Handle specific errors
                        // Use status code to identify the error
                        switch statusCode {
                        case 401:
                            completion(.failure(.notFound))
                            return
                        default:
                            break
                        }
                    }
                }
                completion(.failure(.unexpectedResponse))
            case .failure:
                // HTTP Request failed
                completion(.failure(.requestFailed))
            }
        }
    }
}
