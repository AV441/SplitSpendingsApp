//
//  LabelCell.swift
//  SplitSpendings
//
//  Created by Андрей on 03.10.2022.
//

import UIKit

class LabelCell: UITableViewCell {
    
    static let identifier = "LabelCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(label)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(_ cellType: CellType, with expense: GeneralExpense?) {
        switch cellType {
        
        case .dateLabelCell:
            label.text = Date.now.formatted
            
            if let expense = expense {
                label.text = expense.date.formatted
            }
        case .payerLabelCell:
            if let person = accounts[indexOfCurrentAccount].participants.first {
                label.text = person.name
            }
            
            if let expense = expense {
                label.text = expense.payer.name
            }
            
        default:
            break
        }
    }
}
