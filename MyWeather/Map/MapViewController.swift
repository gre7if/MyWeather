//
//  MapViewController.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils

// Класс для создания карты Google Maps с городами из списка
final class MapViewController: UIViewController {
            
    // переменная для получения данных
    var interactor: MapInteractorInput?
    // переменная для отображения данных
    private weak var presenter: MapViewModelDataSource?
    
    // MARK: - Model
    private var markers: [GMSMarker]?
    private var viewModel: MarkerWeatherViewModel?
    private var presentedMarker: GMSMarker?
        
    // MARK: - Views
    private lazy var contentView = MapView()
    private var mapView: GMSMapView { contentView.mapView }
    private var clusterManager: GMUClusterManager!

    // MARK: - Lifecycle
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // запрашиваем Interactor получить данные
        interactor?.reloadData()
    }
    
    // функция для кластеризации городов на карте
    private func clusterCities() {
        // создаем clusterManager
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        guard let markers = markers else { return }
        clusterManager.add(markers)
        clusterManager.cluster()
    }
}

extension MapViewController: GMSMapViewDelegate {
    
    // функция-обработчик нажатия на маркер
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // перемещаем карту на нажатый маркер
        mapView.animate(toLocation: marker.position)
        // если был нажат кластер
        if let _ = marker.userData as? GMUCluster {
            // увеличиваем масштаб карты на 1
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            NSLog("Did tap cluster")
            return true
        }
        // если был нажат маркер
        NSLog("Did tap a normal marker")
        
        presentedMarker = marker
        marker.title = nil
        marker.snippet = "\n\n       loading...      \n\n"
        marker.map = mapView
        // загружаем данные по маркеру
        interactor?.reloadWeatherData(coord: marker.position)
    
        return false
    }
}

extension MapViewController: MapPresenterDelegate {
    
    func presenterDidReloadData(_ presenter: MapViewModelDataSource) {
        DispatchQueue.main.async {
            self.markers = presenter.objects
            self.clusterCities()
        }
    }
    
    func presenterDidReloadWeatherData(_ presenter: MapViewModelDataSource) {
        DispatchQueue.main.async {
            self.viewModel = presenter.weather
            
            guard
                let marker = self.presentedMarker,
                let viewModel = self.viewModel
            else { return }
            
            // отображаем данные из API-запроса
            marker.title = viewModel.name
            marker.snippet = "Country \(viewModel.country)\nTemp \(viewModel.temp)\nClouds \(viewModel.clouds), Humidity \(viewModel.humidity), Pressure \(viewModel.pressure)\nWind Direction \(viewModel.windDeg), Wind Speed \(viewModel.windSpeed)"
            marker.map = self.mapView
        }
    }
}

