//
//  ViewController.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit

// View Controller - реагирует на нажатие пользователя, посылает запрос Interactor для получения данных

// Класс для отображения списка городов
class CityViewController: UIViewController {
    
    // переменная для получения данных
    var interactor: CityInteractorInput?
    // переменная для отображения данных
    private weak var presenter: CityViewModelDataSource?
    
    // MARK: - Views
    
    private lazy var contentView = CityView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var tableView: UITableView { contentView.tableView }
    
    // функция для настройки отображения UI-элементов
    private func configureUI() {
        title = "Cities"
        // большой шрифт заголовка
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.barTintColor = .blue
        // убираем полупрозрачность заголовка
        navigationController?.navigationBar.isTranslucent = false
        // делаем стиль черным, чтобы все, что внутри, стало белым (заголовок и строка состояния)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        // settings for searchController
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
//        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.obscuresBackgroundDuringPresentation = false
        // ??
        navigationController?.definesPresentationContext = true
        // не скрываем панель поиска при скроллинге вверх
//        navigationItem.hidesSearchBarWhenScrolling = false
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        // запрашиваем Interactor получить данные
        interactor?.reloadData()
    }
}

// MARK: UITableViewDataSource

// отображаем данные от Presenter в таблице
extension CityViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = self.presenter else { return 0 }
        return presenter.numberOfRowsInSection(at: section)
    }

    // вызывается для каждой строки в табличном представлении
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.identifier, for: indexPath) as? CityTableViewCell,
            let presenter = self.presenter
        else {
            return UITableViewCell()
        }
        cell.configureCell(with: presenter.object(at: indexPath))
        return cell
    }

    // метод для установки названия раздела
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter?.sectionName(at: section)
    }
    
    // метод для возврата названий разделов
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return presenter?.sectionIndexTitles
    }
    
    // метод для возврата индекса раздела с заданным названием и индексов разделов
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return presenter?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
}

extension CityViewController: UITableViewDelegate {
    
    // метод для обработки выбора строки
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // запрашиваем данные из presenter по выбранной строке
        guard let cityViewModel = presenter?.object(at: indexPath) else { return }
        // создаем cityWeatherViewController
        let cityWeatherVC = CityWeatherBuilder.build(with: cityViewModel)
        // открываем CityWeatherViewController
        navigationController?.pushViewController(cityWeatherVC, animated: true)
    }
}

// MARK: UISearchBarDelegate

extension CityViewController: UISearchBarDelegate {
    
    // Сообщает делегату, что пользователь изменил текст для поиска
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // делаем задержку поискового запроса на 0.5 секунд
        // 1. Отменяет запросы на выполнение, ранее зарегистрированные с помощью perform (_: with: afterDelay :).
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(reload), object: nil)
        // 2. Вызывает метод получателя в текущем потоке с использованием режима по умолчанию после задержки.
        perform(#selector(reload), with: nil, afterDelay: 0.5)
    }
    
    @objc func reload() {
        guard let text = searchController.searchBar.text else { return }
        
        if !text.isEmpty {
            // делаем новый запрос
            interactor?.reloadDataWithSearchText(text: text)
        } else {
            // возвращаем начальный запрос
            interactor?.reloadWithInitialData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // возвращаем начальный запрос
        interactor?.reloadWithInitialData()
    }
}

//MARK:- CityPresenterDelegate

// получаем данные от Presenter и вызываем методы UITableViewDataSource при изменении БД
extension CityViewController: CityPresenterDelegate {
    
    func presenterDidReloadData(_ presenter: CityViewModelDataSource) {
        self.presenter = presenter
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func presenterDidFilterData(_ presenter: CityViewModelDataSource) {
        self.presenter = presenter
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}


