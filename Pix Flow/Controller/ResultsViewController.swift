//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2023.
//

import UIKit

class ResultsViewController: UIViewController {

    var topic: String?
    var fullImageLink: String?
    var photographerPicLink: String?
    var photographerName: String?
    var photographerPageLink: String?
    var currentPageNumber = 1
    var totalPageNumber = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var prevPageButton: UIButton!
    @IBOutlet weak var pageCountLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        prevPageButton.isEnabled = false
        collectionView.backgroundColor = .systemBackground
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @IBAction func prevPagePressed(_ sender: UIButton) {
        
        nextPageButton.isEnabled = true
        
        if currentPageNumber > 1 {
            currentPageNumber -= 1
            pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber)"
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            if currentPageNumber == 1 {
                prevPageButton.isEnabled = false
            }
        } else {
            prevPageButton.isEnabled = false
        }
    }
    
    @IBAction func nextPagePressed(_ sender: UIButton) {
        
        if currentPageNumber < totalPageNumber {
            currentPageNumber += 1
            prevPageButton.isEnabled = true
            pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber)"
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            if currentPageNumber == totalPageNumber {
                nextPageButton.isEnabled = false
            }
        }
    }
}


//MARK: - MyCollectionViewCellDelegate

extension ResultsViewController: MyCollectionViewCellDelegate {

    func showMessage() {
        DispatchQueue.main.async {
            self.nextPageButton.isHidden = true
            self.prevPageButton.isHidden = true
            self.pageCountLabel.isHidden = true
            
            let label = UILabel()
            label.text = "No photos found \nTry a different search."
            label.numberOfLines = 2
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = UIColor(named: "Label Color")
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

    func updateTotalPageNumber(totalPages: Int) {
        totalPageNumber = totalPages
        DispatchQueue.main.async { [self] in
            pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber)"
        }
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
        return ImageSearcher.imagesPerPage
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.configure(with: topic!, currentPageNumber, indexPath.row)
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




