//
//  DBManager.swift
//  GotGam
//
//  Created by 김삼복 on 25/04/2020.
//  Copyright © 2020 손병근. All rights reserved.
//


import UIKit
import CoreData

class DBManager {
    static let share = DBManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "Gotgam")
           container.loadPersistentStores(completionHandler: { (storeDescription, error) in
               if let error = error as NSError? {
                   
                   fatalError("Unresolved error \(error), \(error.userInfo)")
               }
           })
           return container
       }()

       // MARK: - Core Data Saving support
	
	lazy var context = persistentContainer.viewContext
	func saveContext () {
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

			}
		}
	}
    
    func fetch<T: NSManagedObject>(_ objectType: T.Type) -> [T] {
        let entityName = String(describing: objectType)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let fetchObjects = try context.fetch(fetchRequest) as? [T]
            return fetchObjects ?? [T]()
        } catch let error {
            print("🚨 Could not fetch objects. \(error.localizedDescription)")
            return []
        }
    }
    
//    func fetchGot(id: Int64) -> ManagedGot? {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedGot")
//        fetchRequest.predicate = NSPredicate(format: "id = %lld", id)
//        do {
//            let fetchObjects = try context.fetch(fetchRequest) as? [ManagedGot]
//            return fetchObjects?.first
//        } catch let error {
//            print("🚨 Could not fetch Got. \(error.localizedDescription)")
//            return nil
//        }
//    }
    
    func fetchGot(objectID: NSManagedObjectID?) -> ManagedGot? {
        guard let id = objectID else { return nil }
        return context.object(with: id) as? ManagedGot
    }
    
    func fetchGot(objectIDString: String) -> ManagedGot? {
        
        
        let fetchRequest = NSFetchRequest<ManagedGot>(entityName: "ManagedGot")
        fetchRequest.predicate = NSPredicate(format: "objectIDString == %@", objectIDString)
        
        do {
            let managedGot = try context.fetch(fetchRequest)
            return managedGot.first
        } catch let error {
            print("🚨 Could not fetch objects. \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchTag(hex: String) -> ManagedTag? {
        let fetchRequest = NSFetchRequest<ManagedTag>(entityName: "ManagedTag")
        fetchRequest.predicate = NSPredicate(format: "hex == %@", hex)
        
        do {
            let managedTag = try context.fetch(fetchRequest)
            return managedTag.first
        } catch let error {
            print("🚨 Could not fetch objects. \(error.localizedDescription)")
            return nil
        }
    }
}
