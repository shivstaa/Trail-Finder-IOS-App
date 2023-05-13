//
//  HistoryViewModel.swift
//  Trail Finder
//
//  Created by Shiv Shah on 4/21/23.
//

import Foundation
import SwiftUI
import CoreData

class HistoryViewModel: ObservableObject {
    @Published var historyData: [History] = [History]()
    
    let container = NSPersistentContainer(name: "Trail_Finder")
    
    init() {
        container.loadPersistentStores{ description, error in
            if let error = error {
                print("Failed to initiate \(error.localizedDescription)")
            }
        }
        update()
    }
    func update() {
        let fetch: NSFetchRequest<History> = History.fetchRequest()
        
        do {
            historyData = try container.viewContext.fetch(fetch)
        } catch {
            historyData = []
            print("Value not Found \(error)")
        }
    }
    
    func saveData(location: String, timestamp: Date) {
        let history = History(context: container.viewContext)
        history.location = location
        history.timestamp = timestamp
        
        do {
            try container.viewContext.save()
            update()
        } catch {
            print("SAVE FAILED \(error)")
        }
    }
    
    func deleteData(location: String) {
        let fetch: NSFetchRequest<History> = History.fetchRequest()
        fetch.predicate = NSPredicate(format: "location == %@", location)
        fetch.fetchLimit = 1
        
        do {
            let delete = try container.viewContext.fetch(fetch)
            if let historyDelete = delete.first {
                container.viewContext.delete(historyDelete)
                
                try container.viewContext.save()
                
                update()
            } else {print("Not in list")}
        } catch {print("DELETE FAILED \(error)")}
    }
}
