//
//  MapDataProvider.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 26.08.2021.
//

import Foundation
import CoreData

// протокол для получения данных из БД и передачи их Interactor через делегат
protocol MapDataProviderInput: MapDataSource {
    func reloadData()
    func reloadWeatherData(coord: CLLocationCoordinate2D)
}

// протокол для передачи данных Interactor при изменении БД
protocol MapDataProviderDelegate: AnyObject {
    func providerDidReloadData(_ provider: MapDataProviderInput)
    func providerDidReloadWeatherData(_ provider: MapDataProviderInput)
}

// протокол для преобразования данных из БД в Модель и передачи их Presenter
protocol MapDataSource: AnyObject {
    var objects: [ManagedCity]? { get }
    var weather: Weather? { get }
}

class MapDataProvider: NSObject {
    
    private var coord: CLLocationCoordinate2D?
    private var weatherFromAPI: Weather?
    
    private var frc: NSFetchedResultsController<ManagedCity>!
    // делегат для передачи данных Interactor
    weak var delegate: MapDataProviderDelegate?
    
    override init() {
        super.init()

        let fetchRequest: NSFetchRequest<ManagedCity> = ManagedCity.fetchRequest()
        let sort1 = NSSortDescriptor(key: #keyPath(ManagedCity.name), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = [sort1]
        
        frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: DBManager.shared.context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
    }
    
    // функция для получения города из массива городов по координатам маркера
    private func getCityByCoordinate(markerCoord: CLLocationCoordinate2D, cities: [ManagedCity]?) -> ManagedCity? {
        guard let cities = cities, !cities.isEmpty else { return nil }
        
        var markerCity: ManagedCity?
        
        cities.forEach {
            if $0.lat == markerCoord.latitude && $0.lon == markerCoord.longitude {
                markerCity = $0
            }
        }
        return markerCity
    }

    // функция для создания url-строки (по id города и ключу) для API-запроса
    private func createURLString() -> String {
        guard
            let cities = frc.fetchedObjects,
            let coord = coord,
            let city = getCityByCoordinate(markerCoord: coord, cities: cities)
        else { return "" }
        
        guard
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let key = keys["OpenWeatherMapAPIKey"] as? String
        else { return "" }
                
        return "https://api.openweathermap.org/data/2.5/weather?id=\(city.id)&units=metric&lang=ru&appid=\(key)"
    }
    
    // функция для загрузки данных по url-адресу
    private func getData(from urlString: String) {
        // получаем url-адрес по строке
        guard let url = URL(string: urlString) else { return }
                
        // выполняем запрос на загрузку данных по нашему url-адресу
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            // если получили данные и нет ошибок
            guard let data = data, error == nil else {
                print("something went wrong with getting data...")
                return
            }
            var weather: Weather?
            // преобразовываем data формата JSON в данные типа Weather
            do {
                weather = try JSONDecoder().decode(Weather.self, from: data)
            }
            catch {
                print("\n failed to convert: \(error.localizedDescription)\n")
            }
                        
            guard let self = self else { return }
            self.weatherFromAPI = weather
            self.delegate?.providerDidReloadWeatherData(self)
        }
        task.resume()
    }
}

// получаем данные из БД и преобразуем их в Модель
extension MapDataProvider: MapDataSource {
    
    var objects: [ManagedCity]? {
        return frc.fetchedObjects
    }
    
    var weather: Weather? {
        return weatherFromAPI
    }
}

// получаем данные из БД и передаем их Interactor через делегат
extension MapDataProvider: MapDataProviderInput { // delegate
        
    func reloadData() {
        do {
            try frc.performFetch()
            delegate?.providerDidReloadData(self)
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func reloadWeatherData(coord: CLLocationCoordinate2D) {
        self.coord = coord
        getData(from: createURLString())
    }
}
