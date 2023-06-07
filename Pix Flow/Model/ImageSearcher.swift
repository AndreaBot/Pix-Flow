//
//  ImageSearcher.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

protocol ImageSearcherDelegate {
    func didFindImages(_ model: ImageModel)
    func didFailWithError(error: Error)
}

struct ImageSearcher {
    
    var delegate: ImageSearcherDelegate?
    
    let baseUrl = "https://api.unsplash.com/search/photos/?client_id=GKREyJQ1MCESHa8rBNmBC_70ZcKWVOsmeU1U--edAv4&orientation=portrait&order_by=popular&per_page=30"
    
    
    func getImages(_ query: String, _ pageNumber: Int, _ index: Int)  {
        
        if let encodedText = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let searchUrl = "\(baseUrl)&query=\(encodedText)&page=\(pageNumber)"
            performRequest(with: searchUrl, index  )
        }
    }
    
    func performRequest(with urlString: String, _ index: Int) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let imageModel = parseJSON(safeData, index) {
                        delegate?.didFindImages(imageModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ imageData: Data, _ index: Int) -> ImageModel? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            
            let imgLinkSmall = decodedData.results[index].urls.small
            let imgLinkFull = decodedData.results[index].urls.full
            let imageModel = ImageModel(imgLinkSmall: imgLinkSmall, imgLinkFull: imgLinkFull)
            
            return imageModel
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
