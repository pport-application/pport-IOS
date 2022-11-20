//
//  HistoryItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2022.
//
//

import Foundation
import CoreData


extension HistoryItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HistoryItemEntity> {
        return NSFetchRequest<HistoryItemEntity>(entityName: "HistoryItemEntity")
    }

    @NSManaged public var amount: String?
    @NSManaged public var count: String?
    @NSManaged public var currency: String?
    @NSManaged public var from: String?
    @NSManaged public var net_worth: String?
    @NSManaged public var ticker: String?
    @NSManaged public var type: String?
    @NSManaged public var balance: String?
    @NSManaged public var timestamp: String?
    @NSManaged public var revenue: String?

}

extension HistoryItemEntity : Identifiable {

}
