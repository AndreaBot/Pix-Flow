//
//  FavouritesViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 10/08/2023.
//

import UIKit
import CoreData

class FavouritesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let vibration = UINotificationFeedbackGenerator()
    
    var favourites = [ImageEntity]()
    var selectedItem: ImageEntity?
    var selectedItemPosition: Int?
    var selectedDownloadLocation = ""
    var imgToDownloadLink = ""
    
    let successImage = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen)
    let downloadNsText = NSMutableAttributedString(string: "\nDownload complete")
    let downloadMessage = "The image has been saved to your Photos app"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .systemBackground
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        loadFavourites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadFavourites()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        for image in favourites {
            image.isTapped = false
        }
        saveToCoreData()
    }
    
    func saveToCoreData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving \(error)")
        }
    }
    
    func loadFavourites() {
        do {
            let request = ImageEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            favourites = try context.fetch(request)
            collectionView.reloadData()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
}

//MARK: - UICollectionViewDelegate, DataSource, DelegateFlowLayout

extension FavouritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for (index, image) in favourites.enumerated() {
            if image.isTapped {
                image.isTapped = false
                let indexPathToUpdate = IndexPath(item: index, section: 0)
                collectionView.reloadItems(at: [indexPathToUpdate])
            }
        }
        selectedItem = favourites[indexPath.item]
        selectedItemPosition = indexPath.item
        selectedDownloadLocation = selectedItem!.downloadLocation!
        imgToDownloadLink = (selectedItem?.fullImageLink)!
        
        favourites[indexPath.item].isTapped.toggle()
        collectionView.reloadItems(at: [indexPath])
    }
}


extension FavouritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return favourites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let selectedImage = favourites[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier, for: indexPath) as! MyCollectionViewCell
        cell.setImage(with: favourites[indexPath.item].smallImageLink!)
        cell.downloadButton.isHidden = selectedImage.isTapped == false ? true : false
        cell.deleteButton.isHidden = selectedImage.isTapped == false ? true : false
        cell.imageView.alpha = selectedImage.isTapped == false ? 1 : 0.6
        
        cell.delegate = self
        return cell
    }
}


extension FavouritesViewController: UICollectionViewDelegateFlowLayout {
    
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

//MARK: - MyCollectionViewCellDelegate

extension FavouritesViewController: MyCollectionViewCellDelegate {
    
    func downloadImage() {
        
        ImageSearcher.downloadImage(with: imgToDownloadLink) { image in
            UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.saveImage), nil)
        }
    }
    
    @objc func saveImage(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        } else {
            vibration.notificationOccurred(.success)
            notificationMessage(successImage!, downloadNsText, downloadMessage)
            ImageSearcher.triggerDownloadCount(selectedDownloadLocation)
        }
    }
    
    func notificationMessage(_ image: UIImage, _ nsText: NSMutableAttributedString, _ alertMessage: String) {
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageAttachment.image = image
        
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        
        let nsText = nsText
        nsText.addAttribute(NSAttributedString.Key.strokeWidth, value: -2, range: NSRange(location: 0, length: nsText.length))
        
        fullString.append(nsText)
        
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        alert.setValue(fullString, forKey: "attributedTitle")
        
        self.present(alert, animated: true)
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)})
    }
    
    func alertMessage() {
        
        let alert = UIAlertController(title: "Attention", message: "Are you sure you want to delete the image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            self.deleteImage()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func deleteFromFavourites() {
        
        alertMessage()
    }
    
    func deleteImage() {
        
        context.delete(selectedItem!)
        favourites.remove(at: selectedItemPosition!)
        saveToCoreData()
        collectionView.reloadData()
    }
}

