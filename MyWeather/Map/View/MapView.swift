//
//  MapView.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 18.08.2021.
//

import UIKit
import GoogleMaps

class MapView: UIView {
    
    private(set) lazy var mapView: GMSMapView = {
        let kazanLat = 55.81756303504818
        let kazanLon = 49.108292290708185
        let camera = GMSCameraPosition(latitude: kazanLat, longitude: kazanLon, zoom: 2)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func addSubviews() {
        addSubview(mapView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
