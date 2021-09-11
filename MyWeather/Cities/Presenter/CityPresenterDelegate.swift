//
//  CityPresenterDelegate.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для передачи данных во View Controller при изменении БД
protocol CityPresenterDelegate: AnyObject {
    
    func presenterDidReloadData(_ presenter: CityViewModelDataSource)
    func presenterDidFilterData(_ presenter: CityViewModelDataSource)
}
