//
//  Alerts.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2024.
//

import UIKit

struct Alerts {
    
    static let successImage = UIImage(systemName: "checkmark.circle")?.withTintColor(.systemGreen)
    static let favouriteImage = UIImage(systemName: "heart.circle")?.withTintColor(UIColor(named: "Custom Pink")!)
    
    static let downloadNsText = NSMutableAttributedString(string: "\nDownload complete")
    static let favouriteNsText = NSMutableAttributedString(string: "\nAdded to Favourites")
    
    static let downloadMessage = "The image has been saved to your Photos app"
    static let favouriteMessage = "The image has been added to your favourites"
    
    static func deletionConfirmation(for image: ImageEntity, position: Int, deleteAction: @escaping (ImageEntity, Int) -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Attention", message: "Are you sure you want to delete the image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
            deleteAction(image, position)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }
    
    static func notificationMessage(_ image: UIImage, _ nsText: NSMutableAttributedString, _ alertMessage: String) -> UIAlertController {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageAttachment.image = image
        
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        
        nsText.addAttribute(NSAttributedString.Key.strokeWidth, value: -2, range: NSRange(location: 0, length: nsText.length))
        
        fullString.append(nsText)
        
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        alert.setValue(fullString, forKey: "attributedTitle")
        
        return alert
    }
    
    static func presentTimedAlert(vc: UIViewController, alert: UIAlertController) {
        vc.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            vc.dismiss(animated: true)
        }
    }
}
