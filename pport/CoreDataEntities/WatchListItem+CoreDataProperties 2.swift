//
//  WatchListItem+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 16.11.2022.
//
//

import Foundation
import CoreData


extension WatchListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WatchListItem> {
        return NSFetchRequest<WatchListItem>(entityName: "WatchListItem")
    }

    @NSManaged public var change: Float
    @NSManaged public var change_p: Float
    @NSManaged public var close: Float
    @NSManaged public var code: String?
    @NSManaged public var high: Float
    @NSManaged public var low: Float
    @NSManaged public var open: Float
    @NSManaged public var previousClose: Float
    @NSManaged public var timestamp: Int32
    @NSManaged public var volume: Int32

}

extension WatchListItem : Identifiable {

}
