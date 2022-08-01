//
//  WatchListItem+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 21.03.2022.
//
//

import Foundation
import CoreData


extension WatchListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchListItem> {
        return NSFetchRequest<WatchListItem>(entityName: "WatchListItem")
    }

    @NSManaged public var low: String?
    @NSManaged public var previousClose: String?
    @NSManaged public var close: String?
    @NSManaged public var change: String?
    @NSManaged public var change_p: String?
    @NSManaged public var code: String?
    @NSManaged public var open: String?
    @NSManaged public var timestamp: String?
    @NSManaged public var volume: String?
    @NSManaged public var high: String?

}

extension WatchListItem : Identifiable {

}
