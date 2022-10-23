//
//  Model.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import Foundation

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
