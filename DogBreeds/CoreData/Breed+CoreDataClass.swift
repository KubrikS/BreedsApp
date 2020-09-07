//
//  Breed+CoreDataClass.swift
//  DogBreeds
//
//  Created by Stanislav on 04.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//
//

import Foundation
import CoreData


public class Breed: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Breed> {
        return NSFetchRequest<Breed>(entityName: "Breed")
    }

    @NSManaged public var name: String
    @NSManaged public var link: Set<Link>
}
