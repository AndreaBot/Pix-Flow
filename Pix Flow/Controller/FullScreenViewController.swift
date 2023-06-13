//
//  FullScreenViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 02/06/2023.
//

import UIKit
import NVActivityIndicatorView


class FullScreenViewController: UIViewController {
    
    
    @IBOutlet weak var photographerProfilePicView: UIImageView!
    @IBOutlet weak var photogtapherNameButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    //var color = UIColor(red: 0, green: 0.2, blue: 1, alpha: 1)
    //var type: NVActivityIndicatorType = "BallRotateChase"
    
    var PhotoImage: UIImage?
    var imageLink: String?
    var photographerImage: UIImage?
    var photographerPicLink: String?
    var photographerName: String?
    var photographerPageLink: String?

    var imageSearcher = ImageSearcher()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.startAnimating()
        imageSearcher.fetchImages(with: imageLink ?? "", urlString2: photographerPicLink ?? "", NVActivityIndicatorView: loadingView) { [weak self] (image1, image2) in
            DispatchQueue.main.async {
                self?.imageView.image = image1
                self?.photographerProfilePicView.image = image2
            }
        }
        photographerProfilePicView.layer.cornerRadius = 18
        photogtapherNameButton.setTitle(photographerName, for: .normal)
    }
    
    @IBAction func photographerNameButtonPressed(_ sender: UIButton) {
        if let url = URL(string: photographerPageLink!), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func downloadImage(_ sender: UIBarButtonItem) {
        
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(saveImage), nil)
    }
    
    @objc func saveImage(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        } else {
            downloadMessage()
            downloadButton.title = "Saved"
            downloadButton.tintColor = UIColor(red: 0, green: 0.85, blue: 0.2, alpha: 1)
        }
    }
    
    func downloadMessage() {
        let downloadMessage = UIAlertController(title: "Download complete", message: "The image has been saved in your Photos app", preferredStyle: .alert)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in downloadMessage.dismiss(animated: true, completion: nil)} )
        present(downloadMessage, animated: true)
    }
}

