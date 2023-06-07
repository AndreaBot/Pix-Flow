//
//  MyCollectionViewCell.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 01/06/2023.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var imageSearcher = ImageSearcher()
    
    static let identifier = "MyCollectionViewCell"
    
    var fullImageLink: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageSearcher.delegate = self
    }

    public func configure(with string: String, _ pageNumber: Int, _ index: Int) {
        
        imageSearcher.getImages(string, pageNumber, index)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
}

//MARK: - ImageSearcherDelegate

extension MyCollectionViewCell: ImageSearcherDelegate {
    
    func didFindImages(_ model: ImageModel) {
            self.fetchImage(with: model.imgLinkSmall)
            self.fullImageLink = model.imgLinkFull
    }
    
    func didFailWithError(error: Error) {
        print(error as Any)
    }
    
    func fetchImage(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error! as Any)
                    return
                }

                if let safeData = data {
                    let imageData = safeData
                    let image = UIImage(data: imageData)
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
            task.resume()
        }
    }

    

        
    
}
