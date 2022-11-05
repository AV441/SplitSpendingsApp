//
//  GlobalVariables.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import Foundation

/// Глобальные константы. Давай объединим их по смыслу. Например:
/// ```
/// enum Notifications {
///     case personsHasBeenChanged
///     case appHasBeenEnteredBackground
///     var name: Notification.Name {
///         switch self {
///         case .personsHasBeenChanged:
///             return Notification.Name(rawValue: "personsHasBeenChangedNotification")
///         case .appHasBeenEnteredBackground:
///             return Notification.Name(rawValue: "appHasBeenEnteredBackground")
///         }
///     }
///}
/// ```
/// Ну, или использовать для этого сткруктуру
/// ```
/// struct Notifications {
///     static let personsHasBeenChanged = Notification.Name(rawValue: "personsHasBeenChangedNotification")
/// }
/// ```

/// Обрати внимание на нейминг: обе константы - это имя нотификации, но одна содержит в своём названии `Notification`, а другая - нет. Постарайся придерживаться одного подхода (который ты определяешь для себя сам) при нейминге.
let personsHasBeenChangedNotification = NSNotification.Name(rawValue: "personsHasBeenChangedNotification")
let appHasBeenEnteredBackground = NSNotification.Name(rawValue: "appHasBeenEnteredBackground")

/// Такой код - явный признак, что нужно что-то, что будет загружать счета.
var accounts = [Account]() {
    didSet {
        Account.save(accounts)
    }
}

/// Аналогично - это глобальная константа, причем, она описывает стейт (состояние) - текущих выбранный счет. Должно быть что-то, что отвечает за это.
var indexOfCurrentAccount: Int = 0
