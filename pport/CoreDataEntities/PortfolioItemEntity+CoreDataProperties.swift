//
//  PortfolioItemEntity+CoreDataProperties.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2022.
//
//

import Foundation
import CoreData


extension PortfolioItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PortfolioItemEntity> {
        return NSFetchRequest<PortfolioItemEntity>(entityName: "PortfolioItemEntity")
    }

    @NSManaged public var wallet: Data?
    @NSManaged public var portfolio: Data?

}

extension PortfolioItemEntity : Identifiable {

}
