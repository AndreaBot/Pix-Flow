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
    
    let baseUrl = "https://api.unsplash.com/search/photos/?orientation=portrait"
    
    func getImages(_ query: String, _ pageNumber: Int, loadingView: NVActivityIndicatorView, sortBy: SortType)  {
        if let encodedText = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let searchUrl = "\(baseUrl)&query=\(encodedText)&page=\(pageNumber)&per_page=\(ImageSearcher.imagesPerPage)&order_by=\(sortBy.rawValue)&client_id=\(ImageSearcher.apiKey)"
            performRequest(with: searchUrl, loadingView, sortBy)
        }
    }
    
    func performRequest(with urlString: String, _ loadingView: NVActivityIndicatorView, _ sortBy: SortType) {
        if let url = URL(string: urlString) {
            DispatchQueue.main.async {
                loadingView.startAnimating()
            }
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    delegate?.didFailWithError(error: error)
                    return
                } else if let safeData = data {
                    if var allResults = parseJSON(safeData, loadingView) {
                        
                        //WORKAROUND FOR A BUG WITHIN THE UNSLAPSH API WHERE SORTING RESULTS BY OLDEST RETURNS THE SAME AS SORTING THEM BY POULARITY INSTEAD. THIS WORKAROUND THEREFORE REVERSES THE POPULARITY ORDER BUT AT LEAST THE USER GETS DIFFERENT IMAGES.
                        if sortBy == .oldest {
                            allResults = allResults.reversed()
                        }
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
                return  decodedData.results
            }
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    static func setImages(with urlString1: String, and urlString2: String, _ NVActivityIndicatorView: NVActivityIndicatorView, _ downloadButton: UIBarButtonItem, _ favouriteButton: UIBarButtonItem, _ completion: @escaping (UIImage?, UIImage?) -> Void) {
        
        let linkArray = [urlString1, urlString2]
        let group = DispatchGroup()
        var fullImage: UIImage?
        var photographerProfilePic: UIImage?
        
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
                        fullImage = image
                    case 1:
                        photographerProfilePic = image
                    default:
                        break
                    }
                    DispatchQueue.main.async {
                        completion(fullImage, photographerProfilePic)
                    }
                }
            }
            .resume()
        }
        
        group.notify(queue: .main) {
            NVActivityIndicatorView.stopAnimating()
            completion(fullImage, photographerProfilePic)
            downloadButton.isEnabled = true
            favouriteButton.isEnabled = true
        }
    }
    
    static func downloadImage(with urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print(error)
                    completion(nil)
                    return
                } else if let safeData = data {
                    let image = UIImage(data: safeData)
                    completion(image)
                } else {
                    completion(nil)
                }
            }
            task.resume()
        } else {
            completion(nil)
        }
    }
    
    static func triggerDownloadCount(_ downloadLocation: String) {
        let downloadLocation = URL(string: "\(String(describing: downloadLocation))&client_id=\(apiKey)")
        URLSession.shared.dataTask(with: downloadLocation!).resume()
    }
}

