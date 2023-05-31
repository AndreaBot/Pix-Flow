//
//  Image Data.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import Foundation

struct ImageData: Codable {
    
    let results: [Result]
}

struct Result: Codable {
    let urls : URLS
}
    

struct URLS : Codable {
    let regular : String
}
