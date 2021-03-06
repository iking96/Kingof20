//
//  ActionButton.swift
//  Kof20
//
//  Created by Ishmael King on 10/25/20.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> ()
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .padding(12)
                .background(Color.gray)
                .cornerRadius(6)
        }
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(title: "NEW GAME") { }
    }
}
