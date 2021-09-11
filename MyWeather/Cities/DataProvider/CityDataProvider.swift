//
//  CityDataProvider.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit
import CoreData

// Data Provider - отвечает за получение данных из БД, передачу данных Interactor

class CityDataProvider: NSObject {
        
    private var frc: NSFetchedResultsController<ManagedCity>
    // переменная для хранения начального запроса
    private var frcSaved: NSFetchedResultsController<ManagedCity>?
    // делегат для передачи данных Interactor
    weak var delegate: CityDataProviderDelegate?
    
    override init() {
        let fetchRequest: NSFetchRequest<ManagedCity> = ManagedCity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "(name >= 'A' and name <= 'Z') or (name >= 'А' and name <= 'Я')")
        let sort1 = NSSortDescriptor(key: #keyPath(ManagedCity.name), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort1]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: DBManager.shared.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        
        super.init()

        // создаем наблюдателя self за объектом DBManager.shared.context
        // selector - указывает сообщение, которое DBManager.shared.context отправляет наблюдателю self, чтобы предупредить его о публикации уведомления
        // name - Имя уведомления, которое нужно зарегистрировать для доставки наблюдателю self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(citiesUpdated(notification:)),
            name: NSNotification.Name.NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // функция-обработчик, которая вызывается при изменениях DBManager.shared.context
    @objc
    private func citiesUpdated(notification: NSNotification) {
        do {
            try frc.performFetch()
            delegate?.providerDidReloadData(self)
        }
        catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Core Data
    
    // функция для добавления данных из JSON в Core Data
    private func fetchDataFromFile() {
        // 1. загружаем данные из файла JSON
        let data = NSDataAsset(name: "city.list", bundle: Bundle.main)
        var cityModel: City?
        do {
            guard let data = data?.data else { return }
            // преобразовываем data формата JSON в CityModel
            cityModel = try JSONDecoder().decode(City.self, from: data)
        }
        catch let error {
            print("\n error \(error)\n")
        }
        // 2. добавляем данные из Модели в Core Data
        guard let models = cityModel else { return }
        updateDatabase(with: models.cities)
    }
    
    // функция, которая добавляет города из Модели в БД CoreData
    private func updateDatabase(with bsInfo: [CityInfo]) {        
        print("starting db load")
        let container = DBManager.shared.persistentContainer
        // перейдем в фоновую очередь
        container.performBackgroundTask{ context in // контекст для управления БД в фоновой очереди
            // пакетно добавляем массив городов в таблицу
            try? ManagedCity.batchInsertAllCities(matching: bsInfo, in: context)
            // сохраняем БД после добавления в таблицу
            try? context.save()
            print("done loading db")
        }
    }
    
    // функция, которая удаляет все записи из таблицы "City" БД CoreData
    private func clearDatabase() {
        print("starting db clear")
        let container = DBManager.shared.persistentContainer
        // перейдем в фоновую очередь
        container.performBackgroundTask { context in // контекст для управления БД в фоновой очереди
            // удаляем все записи из таблицы ManagedCity
            try? ManagedCity.deleteAllCities(in: context)
            // сохраняем БД после очищения таблицы
            try? context.save()
            print("done clearing db")
        }
    }
}

// получаем данные из БД и преобразуем их в Модель
extension CityDataProvider: CityDataSource {
    
	var objects: [CityInfo]? {
        guard let objects = frc.fetchedObjects else {
            return nil
        }
        
        return objects.map {
            return CityInfo(id: Int($0.id), name: $0.name ?? "", state: $0.state ?? "", country: $0.country ?? "", coord: Coord(lon: $0.lon, lat: $0.lat))
        }
    }
    
    func object(at indexPath: IndexPath) -> CityInfo {
        let city = frc.object(at: indexPath)
        
        return CityInfo(id: Int(city.id), name: city.name ?? "", state: city.state ?? "", country: city.country ?? "", coord: Coord(lon: city.lon, lat: city.lat))
    }
    
    func objectModelId(at indexPath: IndexPath) -> String? {
        let city = frc.object(at: indexPath)
        let cityUrl = city.objectID.uriRepresentation()

        return cityUrl.absoluteString
    }
    
    var numberOfSections: Int? {
        return frc.sections?.count
    }
    
    var sectionIndexTitles: [String] {
        return frc.sectionIndexTitles
    }
    
    func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int {
        return frc.section(forSectionIndexTitle: title, at: sectionIndex)
    }
    
    func sectionIndexTitle(forSectionName sectionName: String) -> String? {
        return frc.sectionIndexTitle(forSectionName: sectionName)
    }
    
    func numberOfRowsInSection(at index: Int) -> Int {
        guard let sections = frc.sections else { return 0 }
        guard let objects = sections[index].objects else { return 0 }
        
        return objects.count
    }
    
    func sectionName(at index: Int) -> String? {
        return frc.sections?[index].name
    }
}

// получаем данные из БД и передаем их Interactor через делегат
extension CityDataProvider: CityDataProviderInput {
    
    func reloadData() {
        do {
            try frc.performFetch()
            frcSaved = frc
            
            if frc.fetchedObjects?.count == 0 {
                print("\n Data Base is empty")
                fetchDataFromFile()
                
            } else {
                print("\n Data Base is not empty")
//                clearDatabase()
                delegate?.providerDidReloadData(self)
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func reloadDataWithSearchText(text: String?) {
        let fetchRequest: NSFetchRequest<ManagedCity> = ManagedCity.fetchRequest()
        
        guard let text = text else { return }
        fetchRequest.predicate = NSPredicate(format: "name beginswith[c] %@", text)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ManagedCity.name), ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: DBManager.shared.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        try? frc.performFetch()
        delegate?.providerDidReloadData(self)
    }
    
    func reloadWithInitialData() {
        if let fetchedResult = frcSaved {
            frc = fetchedResult
        }
        delegate?.providerDidReloadData(self)
    }
}
