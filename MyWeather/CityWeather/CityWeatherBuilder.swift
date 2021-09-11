//
//  CityWeatherBuilder.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 21.08.2021.
//

import UIKit

// Builder - отвечает за построение модуля CityWeather

class CityWeatherBuilder {
    // функция для создания CityDetailViewController
    static func build(with city: CityViewModel) -> CityWeatherViewController {
        
        let presenter = CityWeatherPresenter()
        let interactor = CityWeatherInterctor(presenter: presenter, city: city)
        let controller = CityWeatherViewController(interactor: interactor)
        
        presenter.controller = controller
        
        return controller
    }
}
