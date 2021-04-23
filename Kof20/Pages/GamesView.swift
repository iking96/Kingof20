//
//  SignInView.swift
//  Kof20
//
//  Created by Ishmael King on 3/28/21.
//

import SwiftUI

struct GamesView: View {
    @StateObject var userController: UserController = UserController()
    @State private var gameId: Int? = nil

    var body: some View {
        VStack {
            ZStack {
                Color.mainHeaderBackground
                VStack {
                    Text("Games")
                    Text("Fetched game id: \(gameId ?? -1)")
                }.padding()
            }
        }.ignoresSafeArea()
        .onAppear() {
            GameRequest().index(accessToken: userController.accessToken()!) { (result) in
                switch result {
                case .success(let response): do { gameId = response[0].id}
                case .failure( _): do {}
                }
            }
        }
    }
}

struct GamesView_Previews: PreviewProvider {
    static var previews: some View {
        GamesView()
    }
}
