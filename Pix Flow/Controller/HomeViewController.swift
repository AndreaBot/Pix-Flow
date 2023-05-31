//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

class HomeViewController: UIViewController {

    var imageSearcher = ImageSearcher()
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var image1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
        imageSearcher.delegate = self
    }
}

//MARK: - UITxtField Delegate

extension HomeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type a keyword"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let topic = searchField.text {
            imageSearcher.getImages(topic)
            
        }
        searchField.text = ""
    }
 
}

//MARK: - ImageSearcherDelegate

extension HomeViewController: ImageSearcherDelegate {
    
    func didFindImages(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.image1.image = image
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

