//
//  WatchlistItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.11.2022.
//
//

import Foundation
import CoreData


extension WatchlistItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchlistItemEntity> {
        return NSFetchRequest<WatchlistItemEntity>(entityName: "WatchlistItemEntity")
    }

    @NSManaged public var change: String?
    @NSManaged public var change_p: String?
    @NSManaged public var close: String?
    @NSManaged public var code: String?
    @NSManaged public var high: String?
    @NSManaged public var low: String?
    @NSManaged public var open: String?
    @NSManaged public var previousClose: String?
    @NSManaged public var timestamp: String?
    @NSManaged public var volume: String?

}

extension WatchlistItemEntity : Identifiable {

}
