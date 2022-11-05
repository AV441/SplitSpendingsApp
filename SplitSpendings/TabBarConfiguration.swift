//
//  TabBarControllerConfiguration.swift
//  SplitSpendings
//
//  Created by Андрей on 19.10.2022.
//

import UIKit

/// Ты правильно выделил создание и настройку контроллера в отдельный метод.
/// Но старайся не использовать глобальные функции / переменные. Ты работаешь в парадигме ООП и описываешь взаимоотношения между объктами.
/// В данном случае ок несколько вариантов:
/// 1) Наследование `class MyTabBarController: UITabBarContoller`, внутри которого происходит нижеописанная настройка
/// 2) Объявление сущности конфигуратора `struct TabBarControllerConfigurator` c методом `func createTabBarController() -> UITabBarController`
/// Для крупных проектов вариант 2 предпочтительней.

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

    /// Старайся не использовать константы (особенно строковые) внутри кода.
    /// Обычно, в начале файла объявляют что-то типа
    /// ```
    /// private struct Constants {
    ///     static let commonTitle = "Совместные счета"
    ///     static let historyTitle = ""История трат"
    /// }
    /// ```
    /// Иконки можно выносить в отдельный `extention UIImage` для всего приложения, тк они обычно переиспользуются
    ///
    /// Для текстов, которые шарятся на все приложение можно завести что-то тип
    /// ```
    /// struct Texts {
    ///     static let textA = ""
    ///     static let textB = ""
    /// }
    /// ```
    let item1 = UITabBarItem(title: "Совместные счета", image: UIImage(systemName: "square.grid.2x2.fill"), tag: 0)
    let item2 = UITabBarItem(title: "Текущий счет", image:  UIImage(systemName: "person.3.fill"), tag: 1)
    let item3 = UITabBarItem(title: "История трат", image:  UIImage(systemName: "list.dash"), tag: 2)
    
    firstTabNavigationController.tabBarItem = item1
    secondTabNavigationController.tabBarItem = item2
    thirdTabNavigationController.tabBarItem = item3
    
    return tabBarController
}
