//
//  TextFieldCell.swift
//  SplitSpendings
//
//  Created by Андрей on 02.10.2022.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    static let identifier = "TextFieldCell"
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 18, weight: .thin)
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(textField)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ])
    }
    
    func configure(_ cellType: CellType, with expense: GeneralExpense?, for indexPath: IndexPath) {
        
        switch cellType {
            
        case .totalCell:
            textField.placeholder = "Сумма"
            textField.keyboardType = .numbersAndPunctuation
            //            textField.addTarget(self, action: #selector(handleValueChange), for: .editingChanged)
            
            if let expense = expense {
                textField.text = String(expense.total)
            }
            
        case .detailsCell:
            textField.placeholder = "Описание"
            
            if let expense = expense {
                textField.text = expense.details
            }
            
        case .personalExpenseCell:
            textField.placeholder = accounts[indexOfCurrentAccount].participants[indexPath.row - 1].name
            textField.keyboardType = .numbersAndPunctuation
            
            if let expense = expense {
                let participants = accounts[indexOfCurrentAccount].participants
                let person = participants[indexPath.row - 1]
                if let personalExpense = person.expenses.first(where: { $0.id == expense.id }) {
                    textField.text = String(personalExpense.spendings)
                }
            }
        default:
            break
        }
    }
    
}
