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
        
        if let encodedText = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let searchUrl = "\(baseUrl)&query=\(encodedText)"
            performRequest(with: searchUrl)
        }
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
                        fetchImage(with: image1Link)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ imageData: Data) -> String? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            let img1Link = decodedData.results[0].urls.regular
            
            return img1Link
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func fetchImage(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let image1Data = safeData
                    let image1 = UIImage(data: image1Data)
                    delegate?.didFindImages(image1)
                }
            }
            task.resume()
        }
    }
    
}
