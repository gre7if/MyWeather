//
//  City.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import Foundation

struct City: Codable {
    let cities: [CityInfo]
}

struct CityInfo: Codable, CustomStringConvertible {
    var description: String {
        return "\(id) \(name) \(state) \(country) \(coord)"
    }
    
    let id: Int
    let name: String
    let state: String
    let country: String
    let coord: Coord
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case state = "state"
        case country = "country"
        case coord = "coord"
    }
}

struct Coord: Codable {
    let lon: Double
    let lat: Double
}
