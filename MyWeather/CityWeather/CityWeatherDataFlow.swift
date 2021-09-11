//
//  CityWeatherDataFlow.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 21.08.2021.
//

import Foundation

// DataFlow - описывает single-directional связь между view controller, interactor, presenter
// не обязательно должен существовать

enum CityWeather {
    // события из view controller в interactor
    enum Event {
        case initial
    }
    
    // Models из interactor в presenter
    enum Data {
        case presentInfo(Weather)
        case presentTitle(CityViewModel)
    }
    
    // ViewModels из presenter в view controller
    enum State {
        case showInfo([WeatherViewModel])
        case showTitle(String)
    }
}
