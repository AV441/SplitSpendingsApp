//
//  UITextField extension.swift
//  SplitSpendings
//
//  Created by Андрей on 06.10.2022.
//

import UIKit

extension UITextField {
    var value: Double {
        guard let string = text,
              let value = Double(string) else { return .zero }
        return value
    }
}
