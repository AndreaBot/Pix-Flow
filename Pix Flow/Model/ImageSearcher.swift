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
            let photographerName = decodedData.results[index].user.name
            let photographerPicLink = decodedData.results[index].user.profile_image.medium
            let photographerPageLink = decodedData.results[index].user.links.html
            
            let imageModel = ImageModel(imgLinkSmall: imgLinkSmall, imgLinkFull: imgLinkFull, photographerName: photographerName, photographerPicLink: photographerPicLink, photographerPageLink: photographerPageLink)
            
            return imageModel
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func fetchImages(with urlString1: String, urlString2: String, completion: @escaping (UIImage?, UIImage?) -> Void) {
        let group = DispatchGroup()
        
        var image1: UIImage?
        var image2: UIImage?

        if let url1 = URL(string: urlString1) {
            let session1 = URLSession(configuration: .default)
            group.enter()
            let task1 = session1.dataTask(with: url1) { (data1, response1, error1) in
                defer {
                    group.leave()
                }
                
                if let error = error1 {
                    print("Error fetching image 1: \(error)")
                    completion(nil, nil)
                    return
                }
                
                if let safeData1 = data1, let fetchedImage1 = UIImage(data: safeData1) {
                    image1 = fetchedImage1
                    DispatchQueue.main.async {
                        completion(image1, image2)
                    }
                }
            }
            task1.resume()
        }

        if let url2 = URL(string: urlString2) {
            let session2 = URLSession(configuration: .default)
            group.enter()
            let task2 = session2.dataTask(with: url2) { (data2, response2, error2) in
                defer {
                    group.leave()
                }
                
                if let error = error2 {
                    print("Error fetching image 2: \(error)")
                    completion(nil, nil)
                    return
                }
                
                if let safeData2 = data2, let fetchedImage2 = UIImage(data: safeData2) {
                    image2 = fetchedImage2
                    DispatchQueue.main.async {
                        completion(image1, image2)
                    }
                }
            }
            task2.resume()
        }

        group.notify(queue: .main) {
            completion(image1, image2)
        }
    }
}
