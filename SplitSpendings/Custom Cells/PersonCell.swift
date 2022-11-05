//
//  PersonCell.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import UIKit

class PersonCell: UITableViewCell {
    
    static let identifier = "PersonCell"
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .light)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let chartView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    var x: Double = 0
    var balanceIsPositive = true
    var path = UIBezierPath()
    let shape = CAShapeLayer()
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        //Path part
        let width = chartView.bounds.width/2 * abs(x)
        var originX = CGFloat()
        
        switch balanceIsPositive{
        case true:
            originX = chartView.bounds.midX
        case false:
            originX = chartView.bounds.midX - width
        }

        path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: originX, y: chartView.bounds.minY),
                                                size: CGSize(width: width, height: chartView.bounds.height)), cornerRadius: 0)
        
        //Shape part
        shape.path = path.cgPath
        shape.lineWidth = 1.0
        chartView.layer.addSublayer(shape)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(chartView)
        
        contentView.addSubview(stackView)
        contentView.addSubview(balanceLabel)
        contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setConstraints()
    }
    
    func configure(person: Person) {
        nameLabel.text = person.name
        balanceLabel.text = "Баланс: \(round(person.balance * 100) / 100) \(accounts[indexOfCurrentAccount].currency.rawValue)"

        let total = accounts[indexOfCurrentAccount].expenses.reduce(0) { $0 + $1.total }
        if total != 0 {
            x = Double(person.balance) / total
        } else {
            x = 0
        }

        if person.balance >= 0 {
            balanceIsPositive = true
            shape.fillColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            chartView.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).withAlphaComponent(0.3)
        } else {
            balanceIsPositive = false
            shape.fillColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            chartView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).withAlphaComponent(0.3)
        }
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        NSLayoutConstraint.activate([
            balanceLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5),
            balanceLabel.centerXAnchor.constraint(equalTo: chartView.centerXAnchor)
        ])
    }
}
