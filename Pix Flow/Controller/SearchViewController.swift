//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet var categoryButtons: [UIButton]!
    
    var topic: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(image: UIImage(named: "VC Title"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        for button in categoryButtons {
            button.layer.cornerRadius = 10
        }
        searchBackground.layer.cornerRadius = 10
        searchButton.layer.cornerRadius = 5
        searchField.attributedPlaceholder = NSAttributedString(
            string: "Type a keyword",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        searchField.delegate = self
        let exitKeyboard = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(exitKeyboard)
        
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchField.text = ""
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        setupSearch()
    }
    
    @IBAction func searchCategory(_ sender: UIButton) {
        
        if sender.currentTitle == "B&W" {
            topic = "monochrome"
        } else {
            topic = sender.currentTitle
        }
        searchField.endEditing(true)
        performSegue(withIdentifier: "goToResults", sender: self)
        
    }
    
    func setupSearch() {
        if searchField.text != "" {
            topic = searchField.text
            searchField.endEditing(true)
            performSegue(withIdentifier: "goToResults", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            if let destinationVC = segue.destination as? ResultsViewController {
                destinationVC.topic = topic
            }
        }
    }
}


//MARK: - UITxtField Delegate

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        setupSearch()
        return true
    }
}

