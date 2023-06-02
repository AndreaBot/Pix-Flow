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
    var selectedImage: UIImage?
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var image1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.size.width / 2, height: 500)
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}


//MARK: - UICollectionViewDelegate, DataSource, DelegateFlowLayout

extension ResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell {
            selectedImage = selectedCell.imageView.image!
        }
        
        performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreen" {
            let destinationVC = segue.destination as? FullScreenViewController
            destinationVC?.image = selectedImage
        }
    }
    
}

extension ResultsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        
        cell.configure(with: topic!, indexPath.row)
        return cell
    }
}

extension ResultsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3, height: 300)

    }
}


