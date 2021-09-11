//
//  MapPresenter.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 26.08.2021.
//

import Foundation
import GoogleMaps

// протокол для получения данных от Interactor при изменении БД
protocol MapPresenterInput: AnyObject {
    func interactorDidReloadData(_ interactor: MapInteractorInput)
    func interactorDidReloadWeatherData(_ interactor: MapInteractorInput)
}

// протокол для преобразования данных Модели во ViewModels
protocol MapViewModelDataSource: AnyObject {
    var objects: [GMSMarker]? { get }
    var weather: MarkerWeatherViewModel? { get }
}

// протокол для передачи данных во View Controller при изменении БД
protocol MapPresenterDelegate: AnyObject {
    func presenterDidReloadData(_ presenter: MapViewModelDataSource)
    func presenterDidReloadWeatherData(_ presenter: MapViewModelDataSource)
}

class MapPresenter {
    
    // переменная для получения данных от Data Provider
    weak var dataSource: MapDataSource?
    // делегат для передачи данных View Controller
    weak var delegate: MapPresenterDelegate?
    
    // функция для создания массива 10000 маркеров случайных городов из массива городов
    private func createRandomMarkersFromCity(cities: [ManagedCity]?) -> [GMSMarker] {
        guard let cities = cities, !cities.isEmpty else { return [] }
        
        var markers = [GMSMarker]()
        let uniqueIndexes = Int.getUniqueRandomNumbers(min: 0, max: cities.count, count: 10000)
        
        uniqueIndexes.forEach { index in
            autoreleasepool {
                guard let lat = cities[safe: index]?.lat, let lon = cities[safe: index]?.lon else { return }
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                markers.append(marker)
            }
        }
        return markers
    }
}

// преобразуем полученные от Data Provider данные во ViewModels
extension MapPresenter: MapViewModelDataSource { // dataSource
    
    var objects: [GMSMarker]? {
        createRandomMarkersFromCity(cities: dataSource?.objects)
    }
    
    var weather: MarkerWeatherViewModel? {
        guard let data = dataSource?.weather else { return nil }
        
        guard
            let name = data.name,
            let country = data.sys?.country,
            let temp = data.main?.temp,
            let pressure = data.main?.pressure,
            let humidity = data.main?.humidity,
            let windSpeed = data.wind?.speed,
            let windDeg = data.wind?.deg,
            let clouds = data.clouds?.all
        else { return nil }
        
        return MarkerWeatherViewModel(
            name: name,
            country: country,
            temp: temp,
            pressure: pressure,
            humidity: humidity,
            windSpeed: windSpeed,
            windDeg: windDeg,
            clouds: clouds
        )
    }
}

// получаем данные от Interactor и передаем их View Controller
extension MapPresenter: MapPresenterInput { // dataSource, delegate

    func interactorDidReloadData(_ interactor: MapInteractorInput) {
        delegate?.presenterDidReloadData(self)
    }

    func interactorDidReloadWeatherData(_ interactor: MapInteractorInput) {
        delegate?.presenterDidReloadWeatherData(self)
    }
}
