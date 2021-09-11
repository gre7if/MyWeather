//
//  MapInteractor.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 26.08.2021.
//

import Foundation
import GoogleMaps

// протокол для выполнения запроса от View Controller на загрузку данных
protocol MapInteractorInput {
    func reloadData()
    func reloadWeatherData(coord: CLLocationCoordinate2D)
}

class MapInteractor {
    
    private let asyncQueue = DispatchQueue(label: "com.map.interactor", qos: .userInitiated)

    // переменная для передачи данных Presenter
    var presenter: MapPresenterInput?
    // переменная для запроса Data Provider на получение данных
    var dataProvider: MapDataProviderInput?
}

extension MapInteractor: MapDataSource {
    var objects: [ManagedCity]? {
        dataProvider?.objects
    }
    
    var weather: Weather? {
        dataProvider?.weather
    }
}

// запрашиваем Data Provider загрузить данных
extension MapInteractor: MapInteractorInput {
    
    func reloadData() {
        asyncQueue.async { [weak self] in
            self?.dataProvider?.reloadData()
        }
    }

    func reloadWeatherData(coord: CLLocationCoordinate2D) {
        asyncQueue.async { [weak self] in
            self?.dataProvider?.reloadWeatherData(coord: coord)
        }
    }
}

// получаем данные от Data Provider и передаем их Presenter
extension MapInteractor: MapDataProviderDelegate {

    func providerDidReloadData(_ provider: MapDataProviderInput) {
        presenter?.interactorDidReloadData(self)
    }
    
    func providerDidReloadWeatherData(_ provider: MapDataProviderInput) {
        presenter?.interactorDidReloadWeatherData(self)
    }
}
