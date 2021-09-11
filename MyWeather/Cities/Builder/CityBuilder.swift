//
//  CityBuilder.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 23.08.2021.
//

import Foundation

// Builder - отвечает за создание модуля City
// uni-directional связь между view controller, interactor, presenter

class CityBuilder {
    
    static func build() -> CityViewController {
        
        let cityViewController = CityViewController()
        
        let interactor = CityInteractor()
        let presenter = CityPresenter()
        let dataProvider = CityDataProvider()
        
        cityViewController.interactor = interactor
        interactor.presenter = presenter
        interactor.dataProvider = dataProvider
        dataProvider.delegate = interactor
        presenter.delegate = cityViewController
        presenter.dataSource = interactor
        
        return cityViewController
    }
}
