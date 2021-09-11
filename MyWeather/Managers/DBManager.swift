//
//  DBManager.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 24.08.2021.
//

import Foundation
import CoreData

class DBManager {
    
    static let shared = DBManager()
    
    var persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "DBDataModel")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
    
    // viewContext - контекст для управления БД в основной очереди
    var context: NSManagedObjectContext {
         persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func objectID(with url: URL) -> NSManagedObjectID? {
        persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }
    
    func objectID(with urlString: String) -> NSManagedObjectID? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        return persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }
}
