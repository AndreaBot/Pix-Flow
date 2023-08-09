//
//  MyCollectionViewCell.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 01/06/2023.
//

import UIKit


class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    static let identifier = "MyCollectionViewCell"

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    public func setImage(with urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                if let safeData = data {
                    let imageData = safeData
                    let image = UIImage(data: imageData)!
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
            task.resume()
        }
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MyCollectionViewCell", bundle: nil)
    }
}
