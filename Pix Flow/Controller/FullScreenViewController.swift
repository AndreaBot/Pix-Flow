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
    @IBOutlet weak var photographerNameButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var addFavouriteButton: UIBarButtonItem!
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    
    let vibration = UINotificationFeedbackGenerator()
    
    var coreDataManager = CoreDataManager()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        downloadButton.isEnabled = false
        addFavouriteButton.isEnabled = false
        photographerProfilePicView.layer.cornerRadius = 18
        formatBottomText()
        ImageSearcher.setImages(with: fullImgLink, and: photographerPicLink, loadingView, downloadButton, addFavouriteButton) { [weak self] (image1, image2) in
            DispatchQueue.main.async {
                self?.imageView.image = image1
                self?.photographerProfilePicView.image = image2
            }
        }
    }
    
    func formatBottomText() {
        let attributedString = NSMutableAttributedString(string: "\(String(describing: photographerName)) on Unsplash.com")
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: photographerName.count))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: (photographerName.count)+1, length: 15))
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        photographerNameButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    
    @IBAction func photographerNameButtonPressed(_ sender: UIButton) {
        if let url = URL(string: photographerPageLink), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func addToFavouritesPressed(_ sender: UIBarButtonItem) {
        if let selectedImage = selectedImage {
            coreDataManager.save(image: selectedImage)
            addFavouriteButton.isEnabled = false
            addFavouriteButton.title = "Added"
            vibration.notificationOccurred(.success)
            Alerts.presentTimedAlert(vc: self, alert: Alerts.notificationMessage(Alerts.favouriteImage!, Alerts.favouriteNsText, Alerts.favouriteMessage))
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
            downloadButton.title = "Downloaded"
            downloadButton.isEnabled = false
            ImageSearcher.triggerDownloadCount(downloadLocation)
            vibration.notificationOccurred(.success)
            Alerts.presentTimedAlert(vc: self, alert: Alerts.notificationMessage(Alerts.successImage!, Alerts.downloadNsText, Alerts.downloadMessage))
        }
    }
}

