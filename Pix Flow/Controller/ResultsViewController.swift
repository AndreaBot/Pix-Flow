//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2023.
//

import UIKit

class ResultsViewController: UIViewController {
    
    var imageSearcher = ImageSearcher()
    var topic: String?
    
    @IBOutlet weak var image1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageSearcher.delegate = self
        imageSearcher.getImages(topic!)
    }
}

//MARK: - ImageSearcherDelegate

extension ResultsViewController: ImageSearcherDelegate {
    
    func didFindImages(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.image1.image = image
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


