//
//  TabBarControllerConfiguration.swift
//  SplitSpendings
//
//  Created by Андрей on 19.10.2022.
//

import UIKit

func createTabBarController() -> UITabBarController {
    let tabBarController = UITabBarController()
    
    tabBarController.tabBar.backgroundColor = .white
    tabBarController.tabBar.tintColor = .darkGray
    tabBarController.tabBar.unselectedItemTintColor = .darkGray.withAlphaComponent(0.4)
    
    let firstTabNavigationController = UINavigationController(rootViewController: AccountsVC())
    let secondTabNavigationController = UINavigationController(rootViewController: BalancesVC())
    let thirdTabNavigationController = UINavigationController(rootViewController: HistoryVC())
    
    tabBarController.viewControllers = [
        firstTabNavigationController,
        secondTabNavigationController,
        thirdTabNavigationController
    ]
    
    let item1 = UITabBarItem(title: "Совместные счета", image: UIImage(systemName: "square.grid.2x2.fill"), tag: 0)
    let item2 = UITabBarItem(title: "Текущий счет", image:  UIImage(systemName: "person.3.fill"), tag: 1)
    let item3 = UITabBarItem(title: "История трат", image:  UIImage(systemName: "list.dash"), tag: 2)
    
    firstTabNavigationController.tabBarItem = item1
    secondTabNavigationController.tabBarItem = item2
    thirdTabNavigationController.tabBarItem = item3
    
    return tabBarController
}
