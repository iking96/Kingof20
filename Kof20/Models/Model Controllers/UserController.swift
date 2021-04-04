//
//  UserController.swift
//  Kof20
//
//  Created by Ishmael King on 11/7/20.
//

import Foundation

protocol UserControllerObserver: AnyObject {
    func render(_ controller: UserController)
}

private extension UserController {
    struct Observation {
        weak var observer: UserControllerObserver?
    }
}

extension UserController {
    func addObserver(_ observer: UserControllerObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: UserControllerObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
    
    private func notifyObservers() {
        for (id, observation) in observations {
            // If the observer is no longer in memory, we
            // can clean up the observation for its ID
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            
            observer.render(self);
        }
    }
}

class UserController: ObservableObject {
    @Published var user: User
    @Published var error: Error?
    private var observations = [ObjectIdentifier : Observation]()
    
    init(user: User = User()) {
        self.user = user
        
        signInFromLocalStorage()
    }
    
    func signInUser(username: String, password: String, webRequest: WebRequest = WebRequest()) {
        func clientDone(response: SignInResponse) -> Void {
            DispatchQueue.main.async {
                self.user = User(accessToken: response.accessToken)
                self.error = nil
                self.notifyObservers()
            }
        }
        
        func clientError(error: Error?) -> Void{
            DispatchQueue.main.async {
                self.error = error
                self.notifyObservers()
            }
        }
        
        SignInRequest(webRequest: webRequest).signIn(username: username, password: password){ (result) in
            switch result {
            case .success(let response): clientDone(response: response)
            case .failure(let error): clientError(error: error)
            }
        }
    }
    
    func signOutUser() {
        self.user = User()
        self.error = nil
        self.notifyObservers()
    }
    
    func signInFromLocalStorage() {
        // Simulate call to server which results in unsuccessful signin
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.user = User()
            self.error = nil
            self.notifyObservers()
        }
    }
    
    func accessToken() -> String? {
        return user.accessToken
    }
    
    func isSignedIn() -> Bool {
        return accessToken() != nil
    }
}
