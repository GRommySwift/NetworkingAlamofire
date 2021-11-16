//
//  CurrentUser.swift
//  Networking
//
//  Created by Roman Holovai on 04.11.2021.
//  Copyright © 2021 Roma Holovai. All rights reserved.
//

import Foundation

struct CurrentUser {
    let uid: String
    let name: String
    let email: String
    
    init?(uid: String, data: [String: Any]) {
        guard
            let name = data["name"] as? String,
            let email = data["email"] as? String
        else { return nil }
        
        self.uid = uid
        self.name = name
        self.email = email
    }
}
