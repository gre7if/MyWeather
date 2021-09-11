//
//  WeatherTabBarController.swift
//  MyWeather
//
//  Created by Rustam Nigmatzyanov on 09.08.2021.
//

import UIKit

// Класс для создания контейнера для view controllers - Tab Bar Controller
class WeatherTabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        let cityNavigationVC = UINavigationController(rootViewController: CityBuilder.build())
        let navigationIcon = UITabBarItem(title: "Cities", image: UIImage(systemName: "list.dash"), selectedImage: UIImage(systemName: "list.dash"))
        cityNavigationVC.tabBarItem = navigationIcon
        
        let weatherMapVC = MapBuilder.build()
        let wmvcIcon = UITabBarItem(title: "Map", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map"))
        weatherMapVC.tabBarItem = wmvcIcon
        
        // array of the root view controllers displayed by the tab bar interface
        let controllers = [cityNavigationVC, weatherMapVC]
        self.viewControllers = controllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
}

extension WeatherTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "")")
        return true
    }
}
