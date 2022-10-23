//
//  AccountCell.swift
//  SplitSpendings
//
//  Created by Андрей on 12.10.2022.
//

import UIKit

protocol AccountCellDelegate: AnyObject {
    func deleteAccount(sender: AccountCell)
}

class AccountCell: UICollectionViewCell {
    
    static let identifier = "AccountCell"
    
    weak var delegate: AccountCellDelegate?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .black)
        label.numberOfLines = 2
        return label
    }()
    
    let totalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    let participantsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .ultraLight)
        label.numberOfLines = 2
        return label
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton()
        var configuration = UIImage.SymbolConfiguration(paletteColors: [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)])
        configuration = configuration.applying(UIImage.SymbolConfiguration(pointSize: 30))
        let image = UIImage(systemName: "minus.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let labelsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemYellow
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContentView()
        setConstraints()
    }
    
    private func configureContentView() {
        labelsView.addSubview(titleLabel)
        labelsView.addSubview(totalLabel)
        labelsView.addSubview(participantsLabel)
        contentView.addSubview(labelsView)
        contentView.addSubview(deleteButton)
        contentView.layer.cornerRadius = 20
        
        deleteButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
    }
    
    @objc func deleteAccount() {
        delegate?.deleteAccount(sender: self)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: labelsView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor, constant: -10),
            
            totalLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            totalLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor, constant: 10),
            totalLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor, constant: -10),
            
            participantsLabel.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 5),
            participantsLabel.leadingAnchor.constraint(equalTo: labelsView.leadingAnchor, constant: 10),
            participantsLabel.trailingAnchor.constraint(equalTo: labelsView.trailingAnchor, constant: -5),
            
            labelsView.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            labelsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            labelsView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            labelsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15),
            
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
   
    func configure(account: Account) {
        titleLabel.text = account.title
        
        let total = account.expenses.reduce(0) { $0 + $1.total }
        totalLabel.text = "Расходы: \(total) \(account.currency.rawValue)"
        
        let names = account.participants.map { $0.name }.joined(separator: ", ")
        participantsLabel.text = names
        
        if account == accounts[indexOfCurrentAccount] {
            contentView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } else {
            contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func transformChosenCell(account: Account) {
        if account == accounts[indexOfCurrentAccount] {
            contentView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        } else {
            contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
