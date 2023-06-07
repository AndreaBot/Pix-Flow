//
//  FullScreenViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 02/06/2023.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImage(with: imageLink!)
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
        }
    }
    
    func fetchImage(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error as Any)
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
    
    func downloadMessage() {
        let downloadMessage = UIAlertController(title: "Download complete", message: "The image has been saved in your Photos app", preferredStyle: .alert)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in downloadMessage.dismiss(animated: true, completion: nil)} )
        present(downloadMessage, animated: true)
    }
}
