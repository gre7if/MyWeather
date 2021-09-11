//
//  CityInteractor.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 23.08.2021.
//

import Foundation

// Interactor - отвечает за бизнес-логику, получение данных от Data Provider, передачу сырых данных Presenter

class CityInteractor {
    // переменная для передачи данных Presenter
    var presenter: CityPresenterInput?
    // переменная для запроса Data Provider на получение данных
    var dataProvider: CityDataProviderInput?
}

extension CityInteractor: CityDataSource {
    var objects: [CityInfo]? {
        dataProvider?.objects
    }
    
    func object(at indexPath: IndexPath) -> CityInfo {
        guard let object = dataProvider?.object(at: indexPath) else {
            return CityInfo(
                id: 0,
                name: "",
                state: "",
                country: "",
                coord: Coord(lon: 0, lat: 0)
            )
        }
        return object
    }
    
    func objectModelId(at indexPath: IndexPath) -> String? {
        return dataProvider?.objectModelId(at: indexPath)
    }
    
    var sectionIndexTitles: [String] {
        guard let sectionIndexTitles = dataProvider?.sectionIndexTitles else { return [] }
        return sectionIndexTitles
    }
    
    var numberOfSections: Int? {
        return dataProvider?.numberOfSections
    }
    
    func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int {
        guard let section = dataProvider?.section(forSectionIndexTitle: title, at: sectionIndex) else { return 0 }
        return section
    }
    
    func sectionIndexTitle(forSectionName sectionName: String) -> String? {
        return dataProvider?.sectionIndexTitle(forSectionName: sectionName)
    }
    
    func numberOfRowsInSection(at index: Int) -> Int {
        guard let numberOfRowsInSection = dataProvider?.numberOfRowsInSection(at: index) else { return 0 }
        return numberOfRowsInSection
    }
    
    func sectionName(at index: Int) -> String? {
        return dataProvider?.sectionName(at: index)
    }
}

// запрашиваем Data Provider загрузить данных
extension CityInteractor: CityInteractorInput {
    
    func reloadData() {
        dataProvider?.reloadData()
    }
    
    func reloadDataWithSearchText(text: String?) {
        dataProvider?.reloadDataWithSearchText(text: text)
    }
    
    func reloadWithInitialData() {
        dataProvider?.reloadWithInitialData()
    }
}

// получаем данные от Data Provider и передаем их Presenter при изменении БД
extension CityInteractor: CityDataProviderDelegate {
    
    func providerDidReloadData(_ provider: CityDataProviderInput) {
        presenter?.interactorDidReloadData(self)
    }
    
    func providerDidFilterData(_ provider: CityDataProviderInput) {
        presenter?.interactorDidFilterData(self)
    }
}

