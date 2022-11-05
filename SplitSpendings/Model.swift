//
//  Model.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import Foundation

/// Как и писал в `AppDelegate`, модель аккаунта не должна содерждать никакой логики. Только поля с `title` по `id`
/// Т.е. методы `load`, `save` должны быть методами отдельной сущности, которая работает с аккаунтом
///
/// Кстати, мне кажется, что название модели не отражает ее назначение. Обычно аккаут - это аккаунт пользователя приложения.
/// В данном случае - это совместный счет. Сильно путает.
struct Account: Codable, Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
       return lhs.id == rhs.id
    }
    
    var title: String
    let currency: Currency
    var participants: [Person]
    var expenses: [GeneralExpense]
    var id = UUID()
    
    init(title: String, currency: Currency) {
        self.title = title
        self.currency = currency
        self.participants = []
        self.expenses = []
    }

    /// Не могу комментировать выбранный способ сохранения данных, но строка ниже используется 2 раза: для `Account` и для `Person`
    /// Когда ты вынесешь логику сохранение / загрузки в отдельную сущность, можно будет добавить следующее
    /// ```
    /// class AccountStorage {
    ///    ...
    ///    использование FileManager.defaultDirectory
    ///    ...
    /// }
    /// private extension FileManager {
    ///     var defaultDirectory = .default.urls(for: .documentDirectory, in: .userDomainMask).first!
    /// }
    /// ```
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("accounts").appendingPathExtension("plist")
    
    static func load() -> [Account]? {
        guard let codedAccounts = try? Data(contentsOf: archiveURL) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Account>.self, from: codedAccounts)
    }
    
    static func save(_ accounts: [Account]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedAccounts = try? propertyListEncoder.encode(accounts)
        try? codedAccounts?.write(to: archiveURL, options: .noFileProtection)
    }
}

/// Не держи все модели в одном файле. Можно группировать их по смыслу: аккаунт / траты и тд
enum Currency: String, Codable, CaseIterable {
    case rub = "₽"
    case kzt = "₸"
    case usd = "$"
    case eur = "€"
}

struct GeneralExpense: Codable {
    let total: Double
    let details: String
    let date: Date
    let payer: Person
    var participants: [Person]
    let id: UUID
}

struct Person: Codable {
    
    static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("persons").appendingPathExtension("plist")
    
    var name: String
    var expenses: [PersonalExpense]
    var balance: Double {
        /// Моё почтение за использование `reduce`.
        /// Но если прям докапываться, то тут есть неоптимальный момент: ты проходишься по массиву 2 раза.
        /// В данном случае это экономия на спичках, но через `for` это будет в 2 раза быстрее, хоть и не так красиво.
        let totalSpendings = expenses.reduce(0) { $0 + $1.spendings }
        let totalPayments = expenses.reduce(0) { $0 + $1.payments }
        return totalPayments - totalSpendings
    }
    
    init(name: String) {
        self.name = name
        self.expenses = []
    }
}

struct PersonalExpense: Codable {
    var spendings: Double
    let payments: Double
    let details: String
    let date: Date
    let id: UUID
}

/// Коммент ко всем моделям выше:  в них должны быть только хранимые св-ва и вычисляемые св-ва. (stored / calculated roperties), никаких методов / статичных св-тв.
