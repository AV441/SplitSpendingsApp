//
//  PickerViewCell.swift
//  SplitSpendings
//
//  Created by Андрей on 03.10.2022.
//

import UIKit

class PickerViewCell: UITableViewCell {
    
    static let identifier = "PickerViewCell"
    
    let pickerView = UIPickerView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(pickerView)
        contentView.backgroundColor = .white
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            pickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
