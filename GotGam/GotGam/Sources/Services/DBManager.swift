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
           
           let container = NSPersistentContainer(name: "ManagedGot")
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

		
	
    func fetchGotgam() -> [ManagedGot]{
           var memo = [ManagedGot]()

           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ManagedGot.description())

           do{
               memo = try context.fetch(fetchRequest) as! [ManagedGot]
               print("core data~~~ \(memo)")
           }
           catch{
               print("fetching error")
           }
           return memo
       }

}
