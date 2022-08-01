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
    case noEntity
    case noObject
    case other
    case multipleObjects
}

class CoreDataManager: NSObject {
    
    static let shared: CoreDataManager = CoreDataManager()
    var context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func store(entity: String, attributes: [String: Any]) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: entity, in: context) else {
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
    
    func fetch(entity: String) throws -> [Any] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let objects = try context.fetch(request)
            return objects
        } catch {
            throw CoreDataManagerError.fetch
        }
    }
    
    func remove(entity: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let objects = try context.fetch(request)
            
            for object in objects as! [NSManagedObject] {
                context.delete(object)
            }
            
            try context.save()
        } catch {
            throw CoreDataManagerError.fetch
        }
    }
    
    func update(entity: String, predicate: NSPredicate?, low: String, previousClose: String, close: String, change: String, change_p: String, code: String, open: String, timestamp: String, volume: String, high: String) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        request.predicate = predicate
        do {
            let objects = try context.fetch(request)
            let datas = objects as! [WatchListItem]
            if datas.count > 2 {
                NSLog("Multiple data in CoreData", "")
                throw CoreDataManagerError.multipleObjects
            }
            let data = datas[0]
            data.low = low
            data.previousClose = previousClose
            data.close = close
            data.change = change
            data.change_p = change_p
            data.code = code
            data.`open` = open
            data.timestamp = timestamp
            data.volume = volume
            data.high = high
            try context.save()
        } catch {
            throw CoreDataManagerError.fetch
        }
    }
}
