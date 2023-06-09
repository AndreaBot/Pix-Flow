//
//  FullScreenViewController.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 02/06/2023.
//

import UIKit
import NVActivityIndicatorView


class FullScreenViewController: UIViewController {
    
    @IBOutlet weak var photographerProfilePicView: UIImageView!
    @IBOutlet weak var photogtapherNameButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIBarButtonItem!
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    
    let vibration = UINotificationFeedbackGenerator()
    var photoImage: UIImage?
    var imageLink: String?
    var photographerImage: UIImage?
    var photographerPicLink: String?
    var photographerName: String?
    var photographerPageLink: String?
    var downloadLocation: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadButton.isEnabled = false

        let attributedString = NSMutableAttributedString(string: "\(photographerName!) on Unsplash.com")

        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange(location: 0, length: photographerName!.count))
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: photographerName!.count+1, length: 15))
        
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        
        ImageSearcher.fetchImages(with: imageLink ?? "", urlString2: photographerPicLink ?? "", NVActivityIndicatorView: loadingView, downloadButton) { [weak self] (image1, image2) in
            DispatchQueue.main.async {
                self?.imageView.image = image1
                self?.photographerProfilePicView.image = image2
            }
        }
        photographerProfilePicView.layer.cornerRadius = 18
        photogtapherNameButton.setAttributedTitle(attributedString, for: .normal)
    }

    
    @IBAction func photographerNameButtonPressed(_ sender: UIButton) {
        if let url = URL(string: photographerPageLink!), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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
            downloadMessage()
            downloadButton.title = "Saved"
            downloadButton.isEnabled = false
            triggerDownloadCount()
        }
    }
    
    func downloadMessage() {

        let successImage = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen)

        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageAttachment.image = successImage

        let fullString = NSMutableAttributedString(string: "")

        fullString.append(NSAttributedString(attachment: imageAttachment))

        let downloadText = NSMutableAttributedString(string: "\nDownload complete")
        downloadText.addAttribute(NSAttributedString.Key.strokeWidth, value: -2, range: NSRange(location: 0, length: downloadText.length))
        
        fullString.append(downloadText)

        let alert = UIAlertController(title: "", message: "The image has been saved to your Photos app", preferredStyle: .alert)
        alert.setValue(fullString, forKey: "attributedTitle")

        self.present(alert, animated: true)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)})
    }
    
    func triggerDownloadCount() {
        let downloadLocation = URL(string: "\(downloadLocation!)&client_id=\(ImageSearcher.apiKey)")
        URLSession.shared.dataTask(with: downloadLocation!).resume()
    }
}

