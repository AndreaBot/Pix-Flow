//
//  ImageSearcher.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

protocol ImageSearcherDelegate {
    func didFindImages(_ image: UIImage?)
    func didFailWithError(error: Error)
}

struct ImageSearcher {
    
    var delegate: ImageSearcherDelegate?
    
    
    let baseUrl = "https://api.unsplash.com/search/photos/?client_id=GKREyJQ1MCESHa8rBNmBC_70ZcKWVOsmeU1U--edAv4&orientation=portrait&per_page=1"
    
    
    func getImages(_ query: String)  {
        
        let searchUrl = "\(baseUrl)&query=\(query)"
        performRequest(with: searchUrl)
        
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let image1Link = parseJSON(safeData) {
                        //print(image1Link)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ imageData: Data) -> URL? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            let img1 = decodedData.results[0].urls.regular
            let img1URL = URL(string: img1)
            return img1URL
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
