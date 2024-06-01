//
//  FavouritesViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 10/08/2023.
//

import UIKit

class FavouritesViewController: UIViewController {
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noFavsLabel: UILabel!
    
    var coreDataManager = CoreDataManager()
    
    let vibration = UINotificationFeedbackGenerator()
    
    var selectedItem: ImageEntity?
    var selectedItemPosition: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        navBar.topItem?.title = "My Favourites"
        coreDataManager.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        let hideOverlays = UITapGestureRecognizer(target: self, action: #selector(handleCollectionViewTap(_:)))
        collectionView.addGestureRecognizer(hideOverlays)
    }
    
    @objc func handleCollectionViewTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            collectionView(collectionView, didSelectItemAt: indexPath)
        } else {
            DispatchQueue.main.async {
                if let selectedCell = self.coreDataManager.favourites.firstIndex(where: { imageEntity in
                    imageEntity.isTapped == true
                }) {
                    self.coreDataManager.favourites[selectedCell].isTapped = false
                    self.collectionView.reloadItems(at: [IndexPath(item: selectedCell, section: 0)])
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        coreDataManager.loadFavourites()
    }
}


//MARK: - UICollectionViewDelegate, DataSource, DelegateFlowLayout

extension FavouritesViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for (index, image) in coreDataManager.favourites.enumerated() {
            if image.isTapped {
                image.isTapped = false
                let indexPathToUpdate = IndexPath(item: index, section: 0)
                collectionView.reloadItems(at: [indexPathToUpdate])
            }
        }
        selectedItem = coreDataManager.favourites[indexPath.item]
        selectedItemPosition = indexPath.item
        
        coreDataManager.favourites[indexPath.item].isTapped.toggle()
        collectionView.reloadItems(at: [indexPath])
    }
}

extension FavouritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coreDataManager.favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selectedImage = coreDataManager.favourites[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.setImage(with: coreDataManager.favourites[indexPath.item].smallImageLink!)
        cell.downloadButton.isHidden = selectedImage.isTapped == false ? true : false
        cell.deleteButton.isHidden = selectedImage.isTapped == false ? true : false
        cell.imageView.alpha = selectedImage.isTapped == false ? 1 : 0.6
        
        cell.delegate = self
        return cell
    }
}


//MARK: - MyCollectionViewCellDelegate

extension FavouritesViewController: MyCollectionViewCellDelegate {
    
    func downloadImage() {
        if let selectedItem = selectedItem, let fullImageLink = selectedItem.fullImageLink {
            ImageSearcher.downloadImage(with: fullImageLink) { image in
                UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage), nil)
            }
        }
    }
    
    @objc func saveImage(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        } else {
            if let selectedItem = selectedItem, let downloadLocation = selectedItem.downloadLocation {
                ImageSearcher.triggerDownloadCount(downloadLocation)
                vibration.notificationOccurred(.success)
                Alerts.presentTimedAlert(vc: self, alert: Alerts.notificationMessage(Alerts.successImage!, Alerts.downloadNsText, Alerts.downloadMessage))
            }
        }
    }
    
    func deleteFromFavourites() {
        if let selectedItem = selectedItem, let selectedItemPosition = selectedItemPosition {
            present(Alerts.deletionConfirmation(for: selectedItem, position: selectedItemPosition, deleteAction: { [self] _, _ in
                coreDataManager.deleteImage(selectedImage: selectedItem, selectedItemPosition: selectedItemPosition)
            }), animated: true)
        }
    }
}


//MARK: - CoreDataManagerDelegate

extension FavouritesViewController: CoreDataManagerDelegate {
    func refreshScreen() {
        self.collectionView.reloadData()
        noFavsLabel.alpha = coreDataManager.favourites.isEmpty ? 1 : 0
    }
}
