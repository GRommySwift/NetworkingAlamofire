//
//  WebsiteDescription.swift
//  Networking
//
//  Created by Roman Holovai on 19.10.2021.
//

import Foundation

struct WebsiteDescription: Decodable {
    
    let websiteDescription: String?
    let websiteName: String?
    let courses: [Course]
}
