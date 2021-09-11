//
//  CityDataProviderInput.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для получения данных из БД и передачи их Interactor через делегат
protocol CityDataProviderInput: CityDataSource {
    
    func reloadData()
    
    func reloadDataWithSearchText(text: String?)
    func reloadWithInitialData()
}
