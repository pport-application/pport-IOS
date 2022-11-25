//
//  CurrencyItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.11.2022.
//
//

import Foundation
import CoreData


extension CurrencyItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyItemEntity> {
        return NSFetchRequest<CurrencyItemEntity>(entityName: "CurrencyItemEntity")
    }

    @NSManaged public var code: String?
    @NSManaged public var country: String?
    @NSManaged public var currency: String?
    @NSManaged public var exchange: String?
    @NSManaged public var isin: String?
    @NSManaged public var name: String?
    @NSManaged public var type: String?

}

extension CurrencyItemEntity : Identifiable {

}
