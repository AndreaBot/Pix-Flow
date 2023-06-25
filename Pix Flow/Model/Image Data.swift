//
//  Image Data.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import Foundation

struct ImageData: Codable {
    
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let urls: URLS
    let user: User
}

struct User: Codable {
    let name : String
    let profile_image: Profile_Image
    let links: Links
}

struct Profile_Image: Codable {
    let medium: String
}

struct Links: Codable {
    let html: String
}

struct URLS : Codable {
    let small : String
    let full : String
}

