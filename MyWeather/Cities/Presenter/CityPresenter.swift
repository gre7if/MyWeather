//
//  CityPresenter.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 23.08.2021.
//

import Foundation

// Presenter - отвечает за преобразование сырых данных во ViewModels и передачи их во View Controller для отображения

class CityPresenter {
    // переменная для получения данных от Data Provider
    weak var dataSource: CityDataSource?
    // делегат для передачи данных View Controller
    weak var delegate: CityPresenterDelegate?
}

// преобразуем полученные от Data Provider данные во ViewModels
extension CityPresenter: CityViewModelDataSource {
        
    var objects: [CityViewModel]? {
        guard let objects = self.dataSource?.objects else {
            return nil
        }
        
        return objects.map {
            return CityViewModel(name: $0.name, country: $0.country, id: $0.id)
        }
    }
    
    func object(at indexPath: IndexPath) -> CityViewModel {
        guard let dataProvider = self.dataSource else {
            fatalError("There is no data provider")
        }
        
        let city = dataProvider.object(at: indexPath)
        return CityViewModel(name: city.name, country: city.country, id: city.id)
    }
    
    func objectModelId(at indexPath: IndexPath) -> String? {
        guard let dataProvider = self.dataSource else {
            return nil
        }
        
        return dataProvider.objectModelId(at: indexPath)
    }
    
    var sectionIndexTitles: [String] {
        guard let dataProvider = self.dataSource else {
            fatalError("There is no data provider")
        }
        
        return dataProvider.sectionIndexTitles
    }
    
    var numberOfSections: Int? {
        return dataSource?.numberOfSections
    }
    
    func section(forSectionIndexTitle title: String, at sectionIndex: Int) -> Int {
        guard let dataProvider = self.dataSource else {
            fatalError("There is no data provider")
        }
        
        return dataProvider.section(forSectionIndexTitle: title, at: sectionIndex)
    }
    
    func sectionIndexTitle(forSectionName sectionName: String) -> String? {
        return dataSource?.sectionIndexTitle(forSectionName: sectionName)
    }
    
    func numberOfRowsInSection(at index: Int) -> Int {
        guard let dataProvider = dataSource else { return 0 }
        return dataProvider.numberOfRowsInSection(at: index)
    }
    
    func sectionName(at index: Int) -> String? {
        return dataSource?.sectionName(at: index)
    }
}

// получаем данные от Interactor и передаем их View Controller при изменении БД
extension CityPresenter: CityPresenterInput {
    
    func interactorDidReloadData(_ interactor: CityInteractorInput) {
        delegate?.presenterDidReloadData(self)
    }
    
    func interactorDidFilterData(_ interactor: CityInteractorInput) {
        delegate?.presenterDidFilterData(self)
    }
}


