//
//  AppDelegate.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        /// Аккаунт должен быть простой моделью: структура с набором полей, без логики.
        /// Функция загрузки - это логика.
        /// Загрузкой аккаунта должна заниматься отдельная сущность, назначение которой: операции с моделью `Account` (сохранение, загрузка, обновление). Допустим, `AccountStorage`
        ///
        /// UPD: из-за нейминга, тут почти невозможно понять, что просходит загрузка совместных счетов.
        if let loadedAccounts = Account.load() {
            accounts = loadedAccounts
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}
