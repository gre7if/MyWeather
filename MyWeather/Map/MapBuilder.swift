//
//  MapBuilder.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 26.08.2021.
//

import Foundation

// uni-directional связь между view controller, interactor, presenter

class MapBuilder {
    
    static func build() -> MapViewController {
        
        let weatherMapVC = MapViewController()
        
        let interactor = MapInteractor()
        let presenter = MapPresenter()
        let dataProvider = MapDataProvider()
        
        weatherMapVC.interactor = interactor
        interactor.presenter = presenter
        interactor.dataProvider = dataProvider
        dataProvider.delegate = interactor
        presenter.delegate = weatherMapVC
        presenter.dataSource = interactor
        
        return weatherMapVC
    }
}
