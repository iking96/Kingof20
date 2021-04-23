//
//  SignInRequestHelper.swift
//  Kof20
//
//  Created by Ishmael King on 12/24/20.
//

import Foundation

struct RequestError: Error, Codable {
    let error: String
    let errorCode: String
    let status: Int
    let message: String
}

enum GameRequestError: Error, Equatable {
    case signInError
    case notFound
    case requestFailed
    case unexpectedResponse
}

protocol GameRequestProtocol {
    func index(accessToken: String,
                  completion: @escaping (Result<[GameResponse], GameRequestError>) -> Void)
}

struct GameResponse: Codable, Equatable {
    // TODO: Serialize to a String
    var id: Int
}

struct indexResponse: Decodable {
    var games: [GameResponse]
}

class GameRequest: GameRequestProtocol {
    private let webRequest: WebRequestProtocol

    init(webRequest: WebRequestProtocol = WebRequest()) {
        self.webRequest = webRequest
    }
    
    func index(accessToken: String,
                  completion: @escaping (Result<[GameResponse], GameRequestError>) -> Void) {
        let url = "\(APPURL.BaseURL)/games"

        _ = webRequest.setHeader(key: "AUTHORIZATION", value: "Bearer \(accessToken)")
        _ = webRequest.send(url: url, method: "GET"){ (result) in
            switch result {
            case .success(let jsonData):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                if let gameResponse = try? decoder.decode(indexResponse.self, from: jsonData) {
                    completion(.success(gameResponse.games))
                    return
                } else if let errorResponse = try? decoder.decode(RequestError.self, from: jsonData) {
                    switch errorResponse.status {
                    case 200:
                        // All 200 responses from the index route should be
                        // lists of games -- this is an unexpected result
                        completion(.failure(.unexpectedResponse))
                        return
                    case 401:
                        completion(.failure(.notFound))
                        return
                    default:
                        break
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
