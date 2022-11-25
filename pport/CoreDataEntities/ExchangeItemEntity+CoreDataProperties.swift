//
//  ExchangeItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.11.2022.
//
//

import Foundation
import CoreData


extension ExchangeItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeItemEntity> {
        return NSFetchRequest<ExchangeItemEntity>(entityName: "ExchangeItemEntity")
    }

    @NSManaged public var code: String?
    @NSManaged public var country: String?
    @NSManaged public var countryISO2: String?
    @NSManaged public var countryISO3: String?
    @NSManaged public var currency: String?
    @NSManaged public var name: String?
    @NSManaged public var operatingMIC: String?

}

extension ExchangeItemEntity : Identifiable {

}
