//
//  Location+CoreDataProperties.swift
//  MyLocation
//
//  Created by 龙富宇 on 2018/3/12.
//  Copyright © 2018年 AllenLong. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged var date: Date
    @NSManaged public var locationDescription: String
    @NSManaged public var category: String
    @NSManaged var placemark: CLPlacemark?

}
