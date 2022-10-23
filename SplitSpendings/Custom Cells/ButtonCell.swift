//
//  ButtonCell.swift
//  SplitSpendings
//
//  Created by Андрей on 06.10.2022.
//

import UIKit

class ButtonCell: UITableViewCell {
    
    static let identifier = "ButtonCell"
    
    var button: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "square")
        button.setImage(image, for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(" Разделить поровну", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(button)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
