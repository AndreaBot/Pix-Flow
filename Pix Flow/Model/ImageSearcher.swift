//
//  ImageSearcher.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

protocol ImageSearcherDelegate {
    func didFailWithError(error: Error)
}

class ImageSearcher {
    
    var delegate: ImageSearcherDelegate?
    
    let baseUrl = "https://api.unsplash.com/search/photos/?client_id=GKREyJQ1MCESHa8rBNmBC_70ZcKWVOsmeU1U--edAv4&orientation=portrait&order_by=popular&per_page=20"
    
    
    func getImages(_ query: String, _ pageNumber: Int, completion: @escaping ([String]) -> Void) {
        var imageStringArray: [String] = []
        
        if let encodedText = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let searchUrl = "\(baseUrl)&query=\(String(describing: encodedText))&page=\(pageNumber)"
            
            if let url = URL(string: searchUrl) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { [self] (data, response, error) in
                    if let error = error {
                        delegate?.didFailWithError(error: error)
                        completion(imageStringArray)
                        return
                    }
                    
                    if let safeData = data {
                        if let parsedArray = parseJSON(safeData) {
                            imageStringArray = parsedArray
                        }
                    }
                    completion(imageStringArray)
                }
                task.resume()
            } else {
                completion(imageStringArray)
            }
        } else {
            completion(imageStringArray)
        }
    }
    
    func parseJSON(_ imageData: Data) -> [String]? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            let imageStringArray = decodedData.results.prefix(20).map { $0.urls.small }
            return Array(imageStringArray)
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

