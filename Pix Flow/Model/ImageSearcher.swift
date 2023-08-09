//
//  ImageSearcher.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit
import NVActivityIndicatorView

protocol ImageSearcherDelegate {
    func populateArray(modelArray: [Result])
    func noPhotosFound()
    func updateTotalPageNumber(totalPages: Int)
    func didFailWithError(error: Error)
}


struct ImageSearcher {
    
    var delegate: ImageSearcherDelegate?
    
    static let imagesPerPage = 20
    static let apiKey = "GKREyJQ1MCESHa8rBNmBC_70ZcKWVOsmeU1U--edAv4"
    
    let baseUrl = "https://api.unsplash.com/search/photos/?orientation=portrait&order_by=popular"
    
    func getImages(_ query: String, _ pageNumber: Int, loadingView: NVActivityIndicatorView)  {
        
        if let encodedText = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let searchUrl = "\(baseUrl)&query=\(encodedText)&page=\(pageNumber)&per_page=\(ImageSearcher.imagesPerPage)&client_id=\(ImageSearcher.apiKey)"
            
            performRequest(with: searchUrl, loadingView)
        }
    }
    
    func performRequest(with urlString: String, _ loadingView: NVActivityIndicatorView) {
        
        if let url = URL(string: urlString) {
            DispatchQueue.main.async {
                loadingView.startAnimating()
            }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    delegate?.didFailWithError(error: error)
                    return
                }
                if let safeData = data {
                    if let allResults = parseJSON(safeData, loadingView) {
                        delegate?.populateArray(modelArray: allResults)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ imageData: Data, _ loadingView: NVActivityIndicatorView) -> [Result]? {
        
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ImageData.self, from: imageData)
            
            let totalPhotos = decodedData.total
            let totalPages = decodedData.total_pages
            delegate?.updateTotalPageNumber(totalPages: totalPages)
            
            if totalPhotos < ImageSearcher.imagesPerPage {
                delegate?.noPhotosFound()
                return nil
                
            } else {
                
                let resultsArray = decodedData.results
                return resultsArray
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    static func setImages(with urlString1: String, _ urlString2: String, _ NVActivityIndicatorView: NVActivityIndicatorView, _ downloadButton: UIBarButtonItem, _ completion: @escaping (UIImage?, UIImage?) -> Void) {
        
        let linkArray = [urlString1, urlString2]
        let group = DispatchGroup()
        var image1: UIImage?
        var image2: UIImage?
        
        NVActivityIndicatorView.startAnimating()
        
        for (index, link) in linkArray.enumerated() {
            let url = URL(string: link)
            group.enter()
            
            URLSession.shared.dataTask(with: url!) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    print(error)
                    return
                }
                if let safeData = data {
                    let image = UIImage(data: safeData)
                    
                    switch index {
                    case 0:
                        image1 = image
                    case 1:
                        image2 = image
                    default:
                        break
                    }
                    
                    DispatchQueue.main.async {
                        completion(image1, image2)
                    }
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            NVActivityIndicatorView.stopAnimating()
            completion(image1, image2)
            downloadButton.isEnabled = true
        }
    }
}


