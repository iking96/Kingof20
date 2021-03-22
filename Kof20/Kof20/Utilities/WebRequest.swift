//
//  WebRequest.swift
//  Kof20
//
//  Created by Ishmael King on 11/3/20.
//  Reference: https://gist.github.com/smonn/aa561801b52aeb02d880

import Foundation

protocol URLSessionDataTaskProtocol { func resume() }
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

protocol WebRequestProtocol {
    func setHeader(value: String, key: String) -> WebRequestProtocol
    func setBody(data: Data) -> WebRequestProtocol
    func send(url: String, method: String, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol
}

class WebRequest : WebRequestProtocol {
    var headers: [(value: String, key: String)] = []
    var data: Data? = nil
    
    func setHeader(value: String, key: String) -> WebRequestProtocol {
        self.headers.append((value: value, key: key))
        return self
    }
    
    func setBody(data: Data) -> WebRequestProtocol {
        self.data = data
        return self
    }
    
    func send(url: String, method: String, handler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol {
        var request = URLRequest(url: URL(string: url)!)
        request.httpBody = data
        request.httpMethod = method
         
        let task = URLSession
            .shared
            .dataTask(with: request) { data, _, error in
                if let error = error {
                    handler(.failure(error))
                } else {
                    handler(.success(data ?? Data()))
                }
            }
        task.resume()
        return task
    }
}
