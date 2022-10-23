//
//  HistoryCell.swift
//  SplitSpendings
//
//  Created by Андрей on 09.10.2022.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    static let identifier = "HistoryCell"
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
    
    let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .thin)
        return label
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let stackView = UIStackView(arrangedSubviews: [detailsLabel, participantsLabel],
                                    axis: .vertical,
                                    distribution: .fill,
                                    spacing: 5)
        contentView.addSubview(stackView)
        contentView.addSubview(totalLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stackView.trailingAnchor.constraint(equalTo: totalLabel.leadingAnchor),
            
            totalLabel.topAnchor.constraint(equalTo: topAnchor),
            totalLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            totalLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25)
        ])
    }
}
