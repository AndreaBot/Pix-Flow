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
    
    func didFindImages(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
