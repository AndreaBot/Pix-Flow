//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2023.
//

import UIKit
import NVActivityIndicatorView

var apiKey: String?

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var loadingAnimation: NVActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var prevPageButton: UIButton!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    var searcher = ImageSearcher()
    var topic: String?
    
    var smallImgLink = ""
    var fullImgLink = ""
    var photographerName = ""
    var photographerPicLink = ""
    var photographerPageLink = ""
    var downloadLocation = ""
    
    var currentPageNumber = 1 {
        didSet {
            pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber!)"
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            searcher.getImages(topic!, currentPageNumber, loadingView: loadingAnimation)
            if currentPageNumber == 1 {
                prevPageButton.isEnabled = false
                prevPageButton.alpha = 0.3
            } else {
                prevPageButton.isEnabled = true
                prevPageButton.alpha = 1
            }
            if currentPageNumber == totalPageNumber {
                nextPageButton.isEnabled = false
                nextPageButton.alpha = 0.3
            } else {
                nextPageButton.isEnabled = true
                nextPageButton.alpha = 1
            }
        }
    }
    var totalPageNumber: Int? {
        didSet {
            DispatchQueue.main.async { [self] in
                pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber ?? 0)"
            }
        }
    }
    var searchResults = [Result]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = topic!
        
        prevPageButton.isEnabled = false
        prevPageButton.alpha = 0.3
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        searcher.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        searcher.getImages(topic!, currentPageNumber, loadingView: loadingAnimation)
    }
    
    @IBAction func prevPagePressed(_ sender: UIButton) {
        
        if currentPageNumber > 1 {
            currentPageNumber -= 1
            nextPageButton.isEnabled = true
        }
        prevPageButton.isEnabled = currentPageNumber == 1 ? false : true
    }
    
    @IBAction func nextPagePressed(_ sender: UIButton) {
        
        prevPageButton.isEnabled = true
        currentPageNumber += 1
        nextPageButton.isEnabled = currentPageNumber == totalPageNumber ? false : true
    }
}

//MARK: - ImageSearcherDelegate

extension ResultsViewController: ImageSearcherDelegate {
    
    func populateArray(modelArray: [Result]) {
        DispatchQueue.main.async {
            self.loadingAnimation.stopAnimating()
            self.searchResults = modelArray
            self.collectionView.reloadData()
        }
    }
    
    func noPhotosFound() {
        DispatchQueue.main.async { [self] in
            self.loadingAnimation.stopAnimating()
            self.nextPageButton.isHidden = true
            self.prevPageButton.isHidden = true
            self.pageCountLabel.isHidden = true
            
            let stack = createStackView()
            self.view.addSubview(stack)
            stack.addArrangedSubview(createIconImage())
            stack.addArrangedSubview(createNoPhotosLabel())
            
            NSLayoutConstraint.activate([
                stack.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
            ])
        }
    }
    
    func updateTotalPageNumber(totalPages: Int) {
        totalPageNumber = totalPages
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func createStackView() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
    
    func createIconImage() -> UIImageView {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold, scale: .large)
        let iconImage = UIImage(systemName: "exclamationmark.magnifyingglass")?.withTintColor(.gray).withConfiguration(largeConfig).withRenderingMode(.alwaysOriginal)
        let imageView = UIImageView(image: iconImage)
        return imageView
    }
    
    func createNoPhotosLabel() -> UILabel {
        let label = UILabel()
        label.text = "No photos found \nPlease try a different search."
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        label.textColor = UIColor(named: "Label Color")
        label.textAlignment = .center
        return label
    }
}


//MARK: - UICollectionViewDelegate, DataSource, DelegateFlowLayout

extension ResultsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        smallImgLink = searchResults[indexPath.item].urls.small
        fullImgLink = searchResults[indexPath.item].urls.full
        photographerName = searchResults[indexPath.item].user.name
        photographerPicLink = searchResults[indexPath.item].user.profile_image.medium
        photographerPageLink = searchResults[indexPath.item].user.links.html
        downloadLocation = searchResults[indexPath.item].links.download_location
        
        performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreen" {
            let destinationVC = segue.destination as? FullScreenViewController
            
            destinationVC?.smallImgLink = smallImgLink
            destinationVC?.fullImgLink = fullImgLink
            destinationVC?.photographerName = photographerName
            destinationVC?.photographerPicLink = photographerPicLink
            destinationVC?.photographerPageLink = photographerPageLink
            destinationVC?.downloadLocation = downloadLocation
        }
    }
}

extension ResultsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.setImage(with: searchResults[indexPath.item].urls.small)
        cell.downloadButton.isHidden = true
        cell.deleteButton.isHidden = true
        
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




