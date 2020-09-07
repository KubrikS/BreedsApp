//
//  CoreDataStack.swift
//  DogBreeds
//
//  Created by Stanislav on 26.08.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: CoreDataStack.self)])!
        return managedObjectModel
    }()
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: CoreDataStack.managedObjectModel)
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
