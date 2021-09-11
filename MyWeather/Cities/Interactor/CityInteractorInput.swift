//
//  CityInteractorInput.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для выполнения запроса от View Controller на загрузку данных
protocol CityInteractorInput {
	
	func reloadData()
    
    func reloadDataWithSearchText(text: String?)
    func reloadWithInitialData()
}
