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
}
