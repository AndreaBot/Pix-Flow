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
    var fullImageLink: String?
    var photographerPicLink: String?
    var photographerName: String?
    var photographerPageLink: String?
    var pageNumber = 0
    var totalPageNumber: Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageNumber += 1
        collectionView.backgroundColor = .white
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func loadMorePressed(_ sender: UIButton) {
        if pageNumber + 1 < totalPageNumber! {   //THE LAST PAGE WON'T HAVE ENOUGH IMAGES TO FILL EACH CELL SO IT GETS SKIPPED
            pageNumber += 1
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            collectionView.reloadData()
        } else {
            loadMoreButton.isEnabled = false
            let alert = UIAlertController(title: "End of results", message: "No images left to display.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}


//MARK: - MyCollectionViewCellDelegate

extension ResultsViewController: MyCollectionViewCellDelegate {

    func showAlert() {
        DispatchQueue.main.async {
            self.loadMoreButton.alpha = 0
            
            let label = UILabel()
            label.text = "No photos found \nTry a different search."
            label.numberOfLines = 2
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor.black
            label.textAlignment = .center
            label.center = self.view.center
            let labelWidth: CGFloat = 200
            let labelHeight: CGFloat = 100
            
            label.frame = CGRect(x: self.view.center.x - (labelWidth / 2),
                                 y: self.view.center.y - (labelHeight / 2),
                                 width: labelWidth,
                                 height: labelHeight)
            self.view.addSubview(label)
            
        }
    }

    func updatePageNumber(totalPages: Int) {
        totalPageNumber = totalPages
    }
}


//MARK: - UICollectionViewDelegate, DataSource, DelegateFlowLayout

extension ResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedCell = collectionView.cellForItem(at: indexPath) as? MyCollectionViewCell {
            fullImageLink = selectedCell.fullImageLink
            photographerName = selectedCell.photographerName
            photographerPicLink = selectedCell.photographerProfilePicLink
            photographerPageLink = selectedCell.photographerPageLink
        }
        performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreen" {
            let destinationVC = segue.destination as? FullScreenViewController
            destinationVC?.imageLink = fullImageLink
            destinationVC?.photographerName = photographerName
            destinationVC?.photographerPicLink = photographerPicLink
            destinationVC?.photographerPageLink = photographerPageLink
        }
    }
}

extension ResultsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSearcher.imagesPerPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.configure(with: topic!, pageNumber, indexPath.row)
        cell.delegate = self
        return cell
    }
}

extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let photoWidth: CGFloat = 720.0
        let photoHeight: CGFloat = 1080.0
        let collectionViewWidth = collectionView.bounds.width
        
        let sectionInsetLeftRight: CGFloat = 10.0
        let contentInsetLeftRight = collectionView.contentInset.left + collectionView.contentInset.right
        
        let availableWidth = collectionViewWidth - sectionInsetLeftRight - contentInsetLeftRight
        
        let cellWidth = availableWidth / 2.0
        let cellHeight = (photoHeight / photoWidth) * cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}




