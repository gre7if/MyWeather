//
//  SearchTableViewCell.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit

// View - отвечает за отображение данных

class CityTableViewCell: UITableViewCell {
    static let identifier = "CityTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // тип ячейки - со стрелочкой в правой части
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(with viewModel: CityViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.country
        detailTextLabel?.textColor = .gray
    }
}
