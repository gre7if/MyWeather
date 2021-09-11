//
//  CityWeatherViewController.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 12.08.2021.
//

import UIKit

// View Controller - реагирует на нажатие пользователя, посылает запрос Interactor для загрузки данных
    
// протокол для взаимодействия с Presenter
protocol CityWeatherViewControllerProtocol: AnyObject {
    // функция для получения преобразованных данных от Presenter и отображения их на экране
    func showState(with state: CityWeather.State)
}

// Класс для отображения детальной информации о погоде по выбранному городу из API
class CityWeatherViewController: UIViewController {
    
    // переменная для взаимодействия с Interactor
    private let interactor: CityWeatherInteractorProtocol
    private var viewModels: [WeatherViewModel] = []
    
    // Views
    private lazy var contentView = WeatherView()
    private var tableView: UITableView { contentView.tableView }
    private var spinner: UIActivityIndicatorView { contentView.spinner }
    
    init(interactor: CityWeatherInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        // отмена большого шрифта заголовка
        navigationItem.largeTitleDisplayMode = .never
        tableView.dataSource = self
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        spinner.startAnimating()
        // просим Interactor загрузить данные
        interactor.handleEvent(with: .initial)
    }
}

extension CityWeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as? WeatherTableViewCell,
            let viewModel = viewModels[safe: indexPath.row]
        else {
            return UITableViewCell()
        }
        cell.configureCell(with: viewModel)
        return cell
    }
}

extension CityWeatherViewController: CityWeatherViewControllerProtocol {
    // функция для получения преобразованных данных от Presenter и отображения их на экране
    func showState(with state: CityWeather.State) {
        switch state {
        case let .showInfo(viewModels):
            self.viewModels = viewModels
            spinner.stopAnimating()
            tableView.reloadData()
        case let .showTitle(title):
            navigationItem.title = title
        }
    }
}
