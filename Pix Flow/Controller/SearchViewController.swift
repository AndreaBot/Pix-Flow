//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 29/05/2023.
//

import UIKit

class SearchViewController: UIViewController {
    
    var topic: String?
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchField.delegate = self
//
//        let exitKeyboard = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
//        view.addGestureRecognizer(exitKeyboard)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchField.text = ""
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        
        if searchField.text != "" {
            topic = searchField.text
            searchField.endEditing(true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResults" {
            let destinationVC = segue.destination as? ResultsViewController
            destinationVC?.topic = topic
        }
    }
}


//MARK: - UITxtField Delegate

extension SearchViewController: UITextFieldDelegate {
    
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
        topic = searchField.text
        performSegue(withIdentifier: "goToResults", sender: self)
       
    }
}


