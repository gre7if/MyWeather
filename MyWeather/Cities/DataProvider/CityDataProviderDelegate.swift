//
//  CityDataProviderDelegate.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для передачи данных Interactor при изменении БД
protocol CityDataProviderDelegate: AnyObject {

	func providerDidReloadData(_ provider: CityDataProviderInput)
    func providerDidFilterData(_ provider: CityDataProviderInput)
}

