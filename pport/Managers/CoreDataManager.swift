//
//  CoreDataManager.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 15.02.2022.
//

import UIKit
import CoreData

enum CoreDataManagerError: Error {
    case store
    case fetch
    case batchDelete
    case noEntity
    case noObject
    case other
    case multipleObjects
}

enum CoreDataEntity: String{
    case watchlist = "WatchlistItemEntity"
    case history = "HistoryItemEntity"
    case portfolio = "PortfolioItemEntity"
}

class CoreDataManager: NSObject {
    
    static let shared: CoreDataManager = CoreDataManager()
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func store(entity: CoreDataEntity, attributes: [String: Any]) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: entity.rawValue, in: context) else {
            throw CoreDataManagerError.noEntity
        }
        let newObject = NSManagedObject(entity: entity, insertInto: context)
        
        for key in attributes.keys {
            newObject.setValue(attributes[key], forKey: key)
        }
        
        do {
            try context.save()
        } catch {
            throw CoreDataManagerError.store
        }
    }
    
    func fetch(entity: CoreDataEntity) throws -> [Any] {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
            let objects = try context.fetch(request)
            return objects
        } catch {
            throw CoreDataManagerError.fetch
        }
    }
    
    func remove(entity: CoreDataEntity) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(batchDeleteRequest)

        } catch {
            throw CoreDataManagerError.batchDelete
        }
    }
    
    func removeAll() {
        do {
            try remove(entity: .watchlist)
        } catch {
            NSLog("Unable to remove items in CoreData", "")
        }
    }
    
    func update(entity: CoreDataEntity, predicate: NSPredicate?, low: Float?, previousClose: Float?, close: Float?,
                change: Float?, change_p: Float?, code: String, `open`: Float?, timestamp: Int32?, volume: Int32?, high: Float?) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        request.predicate = predicate
        do {
            let objects = try context.fetch(request)
            let datas = objects as! [WatchlistItemEntity]
            if datas.count > 2 {
                throw CoreDataManagerError.multipleObjects
            }
            let data = datas[0]
            data.low = low != nil ? String(low!) : nil
            data.previousClose = previousClose != nil ? String(previousClose!) : nil
            data.close = close != nil ? String(close!) : nil
            data.change = change != nil ? String(change!) : nil
            data.change_p = change_p != nil ? String(change_p!) : nil
            data.code = code
            data.`open` = `open` != nil ? String(`open`!) : nil
            data.timestamp = timestamp != nil ? String(timestamp!) : nil
            data.volume = volume != nil ? String(volume!) : nil
            data.high = high != nil ? String(high!) : nil
            try context.save()
        } catch {
            throw CoreDataManagerError.fetch
        }
    }
}
