//
//  TickerItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.11.2022.
//
//

import Foundation
import CoreData


extension TickerItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TickerItemEntity> {
        return NSFetchRequest<TickerItemEntity>(entityName: "TickerItemEntity")
    }

    @NSManaged public var code: String?
    @NSManaged public var tickers: NSObject?

}

extension TickerItemEntity : Identifiable {

}
