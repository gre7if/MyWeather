//
//  CityWeatherInteractor.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 21.08.2021.
//

import Foundation

// Interactor - отвечает за бизнес-логику, получение данных, передачу сырых данных Presenter

// протокол для взаимодействия с view controller
protocol CityWeatherInteractorProtocol {
    // функция для обработки события от view controller
    func handleEvent(with event: CityWeather.Event)
}

class CityWeatherInterctor: CityWeatherInteractorProtocol {    
    // переменная для взаимодействия с Presenter
    private let presenter: CityWeatherPresenterProtocol
    private let city: CityViewModel

    init(presenter: CityWeatherPresenterProtocol, city: CityViewModel) {
        self.presenter = presenter
        self.city = city
    }
    
    // функция для обработки события от view controller
    func handleEvent(with event: CityWeather.Event) {
        switch event {
        case .initial:
            // загружаем данные
            getData()
            // передаем заголовок Presenter
            presenter.transformData(with: .presentTitle(city))
        }
    }
    
    // функция для загрузки данных по url-адресу
    private func getData() {
        guard
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let key = keys["OpenWeatherMapAPIKey"] as? String
        else { return }
                
        // формируем url-строку, делаем API-запрос по id города
        let urlString = "https://api.openweathermap.org/data/2.5/weather?id=\(city.id)&units=metric&lang=ru&appid=\(key)"
        // получаем url-адрес по строке
        guard let url = URL(string: urlString) else { return }
                
        // выполняем запрос на загрузку данных по нашему url-адресу
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            // если получили данные и нет ошибок
            guard let data = data, error == nil else {
                // TODO: Alert message
                print("something went wrong with getting data...")
                return
            }
            // преобразовываем data формата JSON в данные типа Weather
            do {
                let weatherModel = try JSONDecoder().decode(Weather.self, from: data)
                // передаем данные Presenter
                self?.presenter.transformData(with: .presentInfo(weatherModel))
            }
            catch {
                // TODO: Alert message
                print("\n failed to convert: \(error.localizedDescription)\n")
                return
            }
        }
        task.resume()
    }
}


