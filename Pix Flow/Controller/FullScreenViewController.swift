//
//  FullScreenViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 02/06/2023.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    @IBAction func downloadImage(_ sender: UIButton) {
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(savedImage), nil)
    }
    
    @objc func savedImage(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        } else {
            downloadMessage()
        }
    }
    
    func downloadMessage() {
        let downloadMessage = UIAlertController(title: "Download complete", message: "The image has been saved in your Photos app", preferredStyle: .alert)
        downloadMessage.addAction(UIAlertAction(title: "OK", style: .default))
        present(downloadMessage, animated: true)
    }
}
