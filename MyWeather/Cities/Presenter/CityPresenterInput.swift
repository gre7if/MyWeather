//
//  CityPresenterInput.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для получения данных от Interactor при изменении БД
protocol CityPresenterInput: AnyObject  {

	func interactorDidReloadData(_ interactor: CityInteractorInput)
	func interactorDidFilterData(_ interactor: CityInteractorInput)
}
