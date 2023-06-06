//
//  Image Data.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import Foundation

struct ImageData: Codable {
    
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let urls : URLS
}
    

struct URLS : Codable {
    let small : String
    let full : String
    
}
