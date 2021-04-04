//
//  ContentView.swift
//  Kof20
//
//  Created by Ishmael King on 10/25/20.
//

import SwiftUI

class MainMenuViewController: ObservableObject, UserControllerObserver {
    @Published var isSignedIn: Bool? = nil
    private let userController: UserController

    init(userController: UserController) {
        self.userController = userController
        userController.addObserver(self)
    }
    
    func render(_ controller: UserController) {
        withAnimation {
            isSignedIn = controller.isSignedIn()
        }
    }
}

struct MainMenuView: View {
    private var userController: UserController
    @StateObject var viewController: MainMenuViewController

    init() {
        let initController = UserController()
        userController = initController
        _viewController = StateObject(wrappedValue: MainMenuViewController(userController: initController))
    }
    
    var body: some View {
        ZStack {
            if viewController.isSignedIn == nil {
                Text("Loading ...")
            } else if viewController.isSignedIn! {
                SignOutView(userController: userController)
            } else {
                SignInView(userController: userController)
            }
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
