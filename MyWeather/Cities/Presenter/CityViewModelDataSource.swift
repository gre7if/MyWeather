//
//  CityViewModelDataSource.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

// протокол для преобразования данных Модели во ViewModels
protocol CityViewModelDataSource: AnyObject {
	
	var objects: [CityViewModel]? { get }
    func object(at indexPath: IndexPath) -> CityViewModel
    func objectModelId(at indexPath: IndexPath) -> String?
    
    var sectionIndexTitles: [String] { get }
    var numberOfSections: Int? { get }
    func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int
    func sectionIndexTitle(forSectionName sectionName: String) -> String?
    func numberOfRowsInSection(at index: Int) -> Int
    func sectionName(at index: Int) -> String?
}
