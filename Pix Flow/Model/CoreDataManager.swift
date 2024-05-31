//
//  CoreDataManager.swift
//  Pix Flow
//
//  Created by Andrea Bottino on 31/05/2024.
//

import CoreData
import UIKit

protocol CoreDataManagerDelegate {
    func refreshScreen()
}

class CoreDataManager {
    
    var delegate: CoreDataManagerDelegate?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var favourites = [ImageEntity]()
    
    func createNewEntity(from result:Result) -> ImageEntity {
        let newEntity = ImageEntity(context: self.context)
        newEntity.smallImageLink = result.urls.small
        newEntity.fullImageLink = result.urls.full
        newEntity.downloadLocation = result.links.download_location
        newEntity.isTapped = false
        newEntity.date = Date()
        return newEntity
    }
    
     func save(image: Result) {
        let newEntity = createNewEntity(from: image)
        favourites.append(newEntity)
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
            DispatchQueue.main.async {
                for image in self.favourites {
                    image.isTapped = false
                }
                self.delegate?.refreshScreen()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func deleteImage(selectedImage: ImageEntity, selectedItemPosition: Int) {
        context.delete(selectedImage)
        favourites.remove(at: selectedItemPosition)
        saveToCoreData()
        delegate?.refreshScreen()
    }
}
