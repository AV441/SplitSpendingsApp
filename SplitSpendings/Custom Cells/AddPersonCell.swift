//
//  AddPersonCell.swift
//  SplitSpendings
//
//  Created by Андрей on 19.10.2022.
//

import UIKit

class AddPersonCell: UITableViewCell {
    
    static let identifier = "AddPersonCell"
    
    let button: UIButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .thin)
        let buttonImage = UIImage(systemName: "plus.circle", withConfiguration: imageConfiguration)
        button.setImage(buttonImage, for: .normal)
        button.tintColor = .lightGray
        
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .thin)]
        
        let title = NSAttributedString(string: " Добавить участника", attributes: attributes)
        button.setAttributedTitle(title, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(button)
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}
