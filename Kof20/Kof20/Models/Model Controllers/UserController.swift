//
//  UserController.swift
//  Kof20
//
//  Created by Ishmael King on 11/7/20.
//

import Foundation

class UserController: ObservableObject {
    @Published private var user: User
    @Published var error: Error?

    init(user: User = User()) {
        self.user = user
    }
    
    func signInUser(username: String, password: String, webRequest: WebRequest = WebRequest()) {
        func clientDone(response: SignInResponse) -> Void {
            DispatchQueue.main.async {
                self.user = User(accessToken: response.accessToken)
                self.error = nil
            }
        }
        
        func clientError(error: Error?) -> Void{
            DispatchQueue.main.async {
                self.error = error
            }
        }
        
        SignInRequest(webRequest: webRequest).signIn(username: username, password: password){ (result) in
            switch result {
            case .success(let response): clientDone(response: response)
            case .failure(let error): clientError(error: error)
            }
        }
    }
    
    func accessToken() -> String? {
        return user.accessToken
    }
    
    func isSignedIn() -> Bool {
        return accessToken() != nil
    }
}
