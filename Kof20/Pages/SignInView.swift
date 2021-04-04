//
//  SignInView.swift
//  Kof20
//
//  Created by Ishmael King on 3/28/21.
//

import SwiftUI

struct SignInView: View {
    @StateObject var userController: UserController = UserController()
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            ZStack {
                Color.mainHeaderBackground
                VStack {
                    TextField("username", text: $username).padding()
                        .background(Color(.white)).autocapitalization(.none).foregroundColor(.black)
                    TextField("password", text: $password).padding()
                        .background(Color(.white)).autocapitalization(.none).foregroundColor(.black)
                    
                    ActionButton(title: "Sign In", action: {
                        userController.signInUser(
                            username: username,
                            password: password
                        )
                    })
                    
                    Text("Resultant Error: \(userController.error as? SignInRequestError == SignInRequestError.notFound ? "error" : "")")
                }.padding()
            }
        }.ignoresSafeArea()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
