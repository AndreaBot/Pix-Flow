//
//  FullScreenViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 02/06/2023.
//

import UIKit
import CoreData
import NVActivityIndicatorView


class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var photographerProfilePicView: UIImageView!
    @IBOutlet weak var photogtapherNameButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var addFavouriteButton: UIBarButtonItem!
    @IBOutlet weak var loadingView: NVActivityIndicatorView!

    let vibration = UINotificationFeedbackGenerator()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var smallImgLink = ""
    var fullImgLink = ""
    var photographerName = ""
    var photographerPicLink = ""
    var photographerPageLink = ""
    var downloadLocation = ""
    
    var selectedImage: Result? {
            didSet {
                if let selectedImage = selectedImage {
                smallImgLink = selectedImage.urls.small
                fullImgLink = selectedImage.urls.full
                photographerName = selectedImage.user.name
                photographerPicLink = selectedImage.user.profile_image.medium
                photographerPageLink = selectedImage.user.links.html
                downloadLocation = selectedImage.links.download_location
            }
        }
    }

    var favourites = [ImageEntity]()
    
    let successImage = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen)
    let favouriteImage = UIImage(systemName: "heart.circle")?.withTintColor(UIColor(named: "Custom Pink")!)
    let downloadNsText = NSMutableAttributedString(string: "\nDownload complete")
    let favouriteNsText = NSMutableAttributedString(string: "\nAdded to Favourites")
    let downloadMessage = "The image has been saved to your Photos app"
    let favouriteMessage = "The image has been added to your favourites"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadButton.isEnabled = false
        addFavouriteButton.isEnabled = false

        let attributedString = NSMutableAttributedString(string: "\(String(describing: photographerName)) on Unsplash.com")

        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: photographerName.count))

        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: (photographerName.count)+1, length: 15))

        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))

        ImageSearcher.setImages(with: fullImgLink, photographerPicLink ,loadingView, downloadButton, addFavouriteButton) { [weak self] (image1, image2) in
            DispatchQueue.main.async {
                self?.imageView.image = image1
                self?.photographerProfilePicView.image = image2
            }
        }
        photographerProfilePicView.layer.cornerRadius = 18
        photogtapherNameButton.setAttributedTitle(attributedString, for: .normal)
    }


    @IBAction func photographerNameButtonPressed(_ sender: UIButton) {
        if let url = URL(string: photographerPageLink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func addToFavouritesPressed(_ sender: UIBarButtonItem) {
        
        let newEntity = ImageEntity(context: self.context)
        newEntity.smallImageLink = smallImgLink
        newEntity.fullImageLink = fullImgLink
        newEntity.downloadLocation = downloadLocation
        newEntity.isTapped = false
        newEntity.date = Date()
        
        self.favourites.append(newEntity)
        addFavouriteButton.isEnabled = false
        addFavouriteButton.title = "Added"
        self.saveToCoreData()
        vibration.notificationOccurred(.success)
        notificationMessage(favouriteImage!, favouriteNsText, favouriteMessage)
        
    }
    
    func saveToCoreData() {
        
        do {
            try context.save()
        } catch {
            print("Error saving \(error)")
        }
    }
    
                      
    @IBAction func downloadImage(_ sender: UIBarButtonItem) {

        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(saveImage), nil)
    }

    @objc func saveImage(_ image: UIImage, error: Error?, context: UnsafeMutableRawPointer?) {
        if let error = error {
            print(error)
            return
        } else {
            vibration.notificationOccurred(.success)
            notificationMessage(successImage!, downloadNsText, downloadMessage)
            downloadButton.title = "Downloaded"
            downloadButton.isEnabled = false
            ImageSearcher.triggerDownloadCount(downloadLocation)
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
}

