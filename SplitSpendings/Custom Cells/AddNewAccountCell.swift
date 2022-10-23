//
//  AddNewAccountCell.swift
//  SplitSpendings
//
//  Created by Андрей on 13.10.2022.
//

import UIKit

class AddNewAccountCell: UICollectionViewCell {
    
    static let identifier = "AddNewAccountCell"
    
    var button: UIButton = {
        let button = UIButton()
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 80, weight: .light)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfiguration)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGray.withAlphaComponent(0.1)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}
