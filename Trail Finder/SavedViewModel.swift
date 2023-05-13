//
//  SavedViewModel.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/21/23.
//

import Foundation
import SwiftUI
import CoreData

class SavedViewModel: ObservableObject {
    @Published var savedData: [Saved] = [Saved]()
    
    let container = NSPersistentContainer(name: "StoreSavedData")
    
    init() {
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("Failed to initiate \(error.localizedDescription)")
            }
        }
        update()
    }
    func update() {
        let fetch: NSFetchRequest<Saved> = Saved.fetchRequest()
        
        do {
            savedData = try container.viewContext.fetch(fetch)
        } catch {
            savedData = []
            print("Value not Found \(error)")
        }
    }
    
    func saveData(name: String, features: String, directions: String, difficulty: String, city: String, rating: Double, thumbnail: String) {
        let saved = Saved(context: container.viewContext)
        saved.name = name
        saved.features = features
        saved.directions = directions
        saved.difficulty = difficulty
        saved.city = city
        saved.rating = rating
        saved.thumbnail = thumbnail
        
        do {
            try container.viewContext.save()
            update()
        } catch {
            print("SAVE FAILED \(error)")
        }
    }
    
    func deleteData(name: String) {
        let fetch: NSFetchRequest<Saved> = Saved.fetchRequest()
        fetch.predicate = NSPredicate(format: "name == %@", name)
        fetch.fetchLimit = 1
        
        do {
            let delete = try container.viewContext.fetch(fetch)
            if let savedDelete = delete.first {
                container.viewContext.delete(savedDelete)
                
                try container.viewContext.save()
                
                update()
            } else {print("Not in list")}
        } catch {print("DELETE FAILED \(error)")}
    }
}
