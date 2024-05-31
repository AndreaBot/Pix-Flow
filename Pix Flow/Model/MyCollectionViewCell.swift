//
//  MyCollectionViewCell.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 01/06/2023.
//

import UIKit

protocol MyCollectionViewCellDelegate {
    func downloadImage()
    func deleteFromFavourites()
}
class MyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: MyCollectionViewCellDelegate?
    
    static let identifier = "MyCollectionViewCell"
    var isTapped = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    @IBAction func downloadPressed(_ sender: UIButton) {
        delegate?.downloadImage()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        delegate?.deleteFromFavourites()
    }
    
    
    func setImage(with urlString: String) {
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                } else if let safeData = data {
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
