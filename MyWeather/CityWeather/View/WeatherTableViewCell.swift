//
//  WeatherTableViewCell.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 12.08.2021.
//

import UIKit

// View - отвечает за отображение данных

class WeatherTableViewCell: UITableViewCell {
    static let identifier = "WeatherTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // .value1 - тип ячейки с деталью в правой части
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with viewModel: WeatherViewModel) {
        textLabel?.text = viewModel.title
        detailTextLabel?.text = viewModel.value
    }
}
