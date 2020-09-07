//
//  Link+CoreDataClass.swift
//  DogBreeds
//
//  Created by Stanislav on 04.09.2020.
//  Copyright © 2020 St. Kubrik. All rights reserved.
//
//

import Foundation
import CoreData


public class Link: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Link> {
        return NSFetchRequest<Link>(entityName: "Link")
    }

    @NSManaged public var url: String?
    @NSManaged public var breed: Breed
    @NSManaged public var isLiked: Bool
}
