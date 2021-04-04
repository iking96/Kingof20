//
//  SignInView.swift
//  Kof20
//
//  Created by Ishmael King on 3/28/21.
//

import SwiftUI

struct SignOutView: View {
    @StateObject var userController: UserController = UserController()
    
    var body: some View {
        VStack {
            ZStack {
                Color.mainHeaderBackground
                VStack {
                    ActionButton(title: "Sign Out", action: {
                        userController.signOutUser()
                    })
                    
                    Text("Resultant Error: \(userController.error as? SignInRequestError == SignInRequestError.notFound ? "error" : "")")
                }.padding()
            }
        }.ignoresSafeArea()
    }
}

struct SignOutView_Previews: PreviewProvider {
    static var previews: some View {
        SignOutView()
    }
}
