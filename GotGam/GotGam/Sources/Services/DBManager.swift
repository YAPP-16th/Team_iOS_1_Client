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
  
    func fetchGotgam() -> [Gotgam]{
           var memo = [Gotgam]()
           
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Gotgam.description())
           
           do{
               memo = try context.fetch(fetchRequest) as! [Gotgam]
               print("core data~~~")
           }
           catch{
               print("fetching error")
           }
           return memo
       }
  
}
