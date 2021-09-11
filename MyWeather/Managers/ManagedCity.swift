//
//  ManagedCity.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit
import CoreData

class ManagedCity: NSManagedObject {
    
    // функция для удаления всех записей из таблицы ManagedCity
   class func deleteAllCities(in context: NSManagedObjectContext) throws {
        let request: NSFetchRequest<ManagedCity> = ManagedCity.fetchRequest()
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)

            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                context.delete(objectData)
            }
        } catch let error {
            print("Detele all data in BS error :", error)
        }
    }
    
    // функция для пакетного добавления всех городов в таблицу ManagedCity.
    class func batchInsertAllCities(matching cityInfos: [CityInfo], in context: NSManagedObjectContext) throws {
        let start = currentTimeMillis()

        var batchCreate: [[String: Any]] = []
        for cityInfo in cityInfos {
            batchCreate.append(
                [
                    "id": cityInfo.id,
                    "name": cityInfo.name,
                    "state": cityInfo.state,
                    "country": cityInfo.country,
                    "lon": cityInfo.coord.lon,
                    "lat": cityInfo.coord.lat
                ])
        }
        print ("-------кол-во добавляемых элементов = \(batchCreate.count)-------")
            
        let batchRequest = NSBatchInsertRequest(entity: ManagedCity.entity(), objects: batchCreate)
//        batchRequest.resultType = .objectIDs
        batchRequest.resultType = .count
        do {
            let result = try context.execute(batchRequest) as! NSBatchInsertResult
//            let changes: [AnyHashable: Any] = [NSInsertedObjectsKey: result.result as? [NSManagedObjectID] ?? []]
//            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            print("Inserted \(result.result!) rows")
            print("Loading time is \(currentTimeMillis() - start) miliseconds")
        } catch {
            print(error)
        }
    }
    
    // функция для подсчета времени выполнения методов
    class func currentTimeMillis() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

