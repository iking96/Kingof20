//
//  URLConstants.swift
//  Kof20
//
//  Created by Ishmael King on 12/24/20.
//

import Foundation

struct APPURL {
    #if DEBUG
    private struct Domains {
        static let Dev = "http://localhost:3000"
    }
    #else
    private struct Domains {
        static let Dev = "https://kingof20.com"
    }
    #endif

    private  struct Routes {
        static let Api = "/api/v1"
    }

    private  static let Domain = Domains.Dev
    private  static let Route = Routes.Api
    private  static let BaseURL = Domain + Route
    
    static var LoginURL: String {
        return Domain  + "/oauth/token"
    }
}
