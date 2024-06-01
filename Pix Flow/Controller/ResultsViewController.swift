//
//  ViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2023.
//

import UIKit
import NVActivityIndicatorView


class ResultsViewController: UIViewController {
    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    @IBOutlet weak var loadingAnimation: NVActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextPageButton: UIButton!
    @IBOutlet weak var prevPageButton: UIButton!
    @IBOutlet weak var pageCountLabel: UILabel!
    
    var searcher = ImageSearcher()
    var topic: String?
    var sortBy: SortType = .popular {
        didSet {
            setupToolbar()
        }
    }
    
    var selectedImage: Result?

    var currentPageNumber = 1 {
        didSet {
            pageCountLabel.text = "\(currentPageNumber)/\(totalPageNumber!)"
            collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            searcher.getImages(topic!, currentPageNumber, loadingView: loadingAnimation, sortBy: sortBy.rawValue)
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
        setupUI()
    }
    
    func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = false
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        searcher.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let topic = topic {
            title = topic
            searcher.getImages(topic, currentPageNumber, loadingView: loadingAnimation, sortBy: sortBy.rawValue)
        }
        
        prevPageButton.isEnabled = false
        prevPageButton.alpha = 0.3
        collectionView.backgroundColor = .systemBackground
        
        setupToolbar()
    }
    
    func setupToolbar() {
        self.navigationItem.rightBarButtonItems = [createMenuButton()]
    }
    
    func setupMenu() -> UIMenu {
        let checkIcon = UIImage(systemName: "checkmark")
        var children = [UIAction]()
        
        for sortType in SortType.allCases {
            let newAction = UIAction(title: "\(sortType.rawValue.capitalized) first", image: sortBy == sortType ? checkIcon : nil) { _ in
                self.sortBy = sortType
                self.currentPageNumber = 1
            }
            children.append(newAction)
        }
        return UIMenu(title: "Sort by:", options: .displayInline, children: children)
    }
    
    func createMenuButton() -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = setupMenu()
        return button.asBarButtonItem()
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
            noContentAvailableView(sfSymbol: "exclamationmark.magnifyingglass", text: "No photos found \nPlease try a different search.")
        }
    }
    
    func updateTotalPageNumber(totalPages: Int) {
        totalPageNumber = totalPages
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


//MARK: - UICollectionViewDelegate, DataSource

extension ResultsViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = searchResults[indexPath.item]
        performSegue(withIdentifier: "goToFullScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToFullScreen" {
            if let destinationVC = segue.destination as? FullScreenViewController {
                destinationVC.selectedImage = selectedImage
            }
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
