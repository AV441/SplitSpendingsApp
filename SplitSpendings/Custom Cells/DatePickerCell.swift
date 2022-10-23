//
//  DatePickerCell.swift
//  SplitSpendings
//
//  Created by Андрей on 02.10.2022.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    static let identifier = "DatePickerCell"
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.date = .now
        datePicker.locale = Locale(identifier: "ru_Ru")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(datePicker)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
} 
