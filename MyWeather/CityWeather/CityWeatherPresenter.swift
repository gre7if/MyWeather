//
//  CityDetailPresenter.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 21.08.2021.
//

import Foundation

// Presenter - отвечает за преобразование сырых данных и передает данные для отображения

// заголовки для таблицы
private enum Title: String, CaseIterable {
        case name = "Город"
        case country = "Страна"
        case temp = "Температура (Цельсий)"
        case description = "Описание"
        case pressure = "Атмосферное давление (гПа)"
        case humidity = "Влажность (%)"
        case windSpeed = "Скорость ветра (м/с)"
        case windDeg = "Направление ветра (градусы)"
        case clouds = "Облачность (%)"
        case sunrise = "Время восхода"
        case sunset = "Время заката"
}

// протокол для взаимодейстия с Interactor
protocol CityWeatherPresenterProtocol {
    // функция для преобразования сырых данных в данные для отображения
    func transformData(with result: CityWeather.Data)
}

class CityWeatherPresenter: CityWeatherPresenterProtocol {
    // переменная для взаимодействия с view controller
    // weak - чтобы не было цикла памяти
    weak var controller: CityWeatherViewControllerProtocol?
    
    // переменная для форматирования UTC-данных с сервера
    // (!!!)вынесем в отдельное свойство, чтобы создать экземпляр dateFormatter один раз, т.к. это очень затратно
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter
    }()
        
    // функция для передачи данных во view controller
    func transformData(with result: CityWeather.Data) {
        switch result {
        // передаем данные для отображения во vc
        case let .presentInfo(weather):
            transformWeather(weather)
        // передаем заголовок во vc
        case let .presentTitle(city):
            controller?.showState(with: .showTitle(city.name))
        }
    }
    
    // функция для преобразования сырых данных в данные для отображения и передачи их во view controller
    private func transformWeather(_ weahter: Weather) {
        guard
            let name = weahter.name,
            let country = weahter.sys?.country,
            let temp = weahter.main?.temp,
            let description = weahter.weather,
            let pressure = weahter.main?.pressure,
            let humidity = weahter.main?.humidity,
            let windSpeed = weahter.wind?.speed,
            let windDeg = weahter.wind?.deg,
            let clouds = weahter.clouds?.all,
            let sunrise = weahter.sys?.sunrise,
            let sunset = weahter.sys?.sunset,
            let weatherDescription = description.first?.weatherDescription
        else { return }
        
        var model = [String]()
        model.append(name)
        model.append(country)
        model.append(String(Int(round(temp))))
        model.append(weatherDescription)
        model.append(String(pressure))
        model.append(String(humidity))
        model.append(String(windSpeed))
        model.append(String(windDeg))
        model.append(String(clouds))
        model.append(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(sunrise))))
        model.append(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(sunset))))
        
        let titles = Title.allCases
        
        // формируем viewModels
        let viewModels: [WeatherViewModel] = titles.enumerated().compactMap {
            guard let value = model[safe: $0.offset] else {
                return nil
            }
            // создаем элемент массива viewModels
            return .init(title: $0.element.rawValue, value: value)
        }
        // обновляем UI
        DispatchQueue.main.async { [weak self] in
            // передаем viewModel во view controller
            self?.controller?.showState(with: .showInfo(viewModels))
        }
    }
}
