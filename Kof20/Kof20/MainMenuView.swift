//
//  ContentView.swift
//  Kof20
//
//  Created by Ishmael King on 10/25/20.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject var userController: UserController = UserController()
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            ZStack {
                Color.mainHeaderBackground
                VStack {
                    TextField("username", text: $username).padding()
                        .background(Color(.white)).autocapitalization(.none)
                    TextField("password", text: $password).padding()
                        .background(Color(.white)).autocapitalization(.none)
                    
                    ActionButton(title: "Sign In", action: {
                        userController.signInUser(
                            username: username,
                            password: password
                        )
                    })
                    
                    Text("Your access token: \(userController.accessToken() ?? "")")
                    Text("Resultant Error: \(userController.error as? SignInRequestError == SignInRequestError.notFound ? "error" : "")")
                }.padding()
            }
        }.ignoresSafeArea()
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
