//
//  GlobalVariables.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import Foundation

let personsHasBeenChangedNotification = NSNotification.Name(rawValue: "personsHasBeenChangedNotification")
let appHasBeenEnteredBackground = NSNotification.Name(rawValue: "appHasBeenEnteredBackground")

var accounts = [Account]() {
    didSet {
        Account.save(accounts)
    }
}

var indexOfCurrentAccount: Int = 0
