//
//  ImageSearcher.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

protocol ImageSearcherDelegate {
    func didFindSmallImage(_ image: UIImage?)
    func didFailWithError(error: Error)
    func didFindFullImage( _ fullImage: UIImage?)
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
                        fetchSmallImage(with: imageModel.imgLinkSmall)
                        fetchfullImage(with: imageModel.imgLinkFull)
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
    
    func fetchSmallImage(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let imageData = safeData
                    let image = UIImage(data: imageData)
                    delegate?.didFindSmallImage(image)
                }
            }
            task.resume()
        }
    }
    
    func fetchfullImage(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    let imageData = safeData
                    let image = UIImage(data: imageData)
                    delegate?.didFindFullImage(image)
                }
            }
            task.resume()
        }
    }
    
}
