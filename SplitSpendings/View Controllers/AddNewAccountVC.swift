//
//  AddAccountView.swift
//  SplitSpendings
//
//  Created by Андрей on 13.10.2022.
//

import UIKit

protocol AddNewAccountVCDelegate: AnyObject {
    func addNewAccount(account: Account)
}

class AddNewAccountVC: UIViewController {
    
    weak var delegate: AddNewAccountVCDelegate?
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Новый счет"
        label.font = .systemFont(ofSize: 18, weight: .black)
        label.textColor = .black
        return label
    }()
    
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Название"
        return textField
    }()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        let currency = Currency.allCases[0].rawValue
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]
        
        let attributedString = NSMutableAttributedString(string: "Валюта: ")
        let attributedCurrency = NSMutableAttributedString(string: currency, attributes: attributes)
        
        attributedString.append(attributedCurrency)
        
        label.attributedText = attributedString
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemYellow
        button.setTitle("Добавить", for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    let currencyPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.layer.cornerRadius = 8
        pickerView.layer.borderColor = UIColor.lightGray.cgColor
        pickerView.layer.borderWidth = 0.2
        return pickerView
    }()
    
    var stackView = UIStackView()
    var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - viewDidLoad -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Новый счет"
        view.backgroundColor = .white
        
        stackView = UIStackView(arrangedSubviews: [titleTextField,
                                                   currencyLabel,
                                                   currencyPickerView,
                                                   saveButton],
                                    axis: .vertical,
                                    distribution: .fill,
                                    spacing: 10)
        
        view.addSubview(stackView)
        
        currencyPickerView.dataSource = self
        currencyPickerView.delegate = self
        
        saveButton.addTarget(self, action: #selector(addNewAccount), for: .touchUpInside)
        
        addObservers()
        setConstraints()
    }
    
    //MARK: addObservers
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    //MARK: setonstraints
    private func setConstraints() {
        bottomConstraint = saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            currencyLabel.heightAnchor.constraint(equalToConstant: 44),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

//MARK: - UIPickerViewDataSource -

extension AddNewAccountVC: UIPickerViewDataSource {
    
    //MARK: numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    //MARK: numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Currency.allCases.count
    }
    
    //MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Currency.allCases[row].rawValue
    }
}

//MARK: - UIPickerViewDelegate -

extension AddNewAccountVC: UIPickerViewDelegate {
    
    //MARK: didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currency = Currency.allCases[row].rawValue
        
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 20, weight: .medium)
        ]
        
        let attributedString = NSMutableAttributedString(string: "Валюта: ")
        let attributedCurrency = NSMutableAttributedString(string: currency, attributes: attributes)
        
        attributedString.append(attributedCurrency)
        
        currencyLabel.attributedText = attributedString
    }
}

//MARK: - @objc Methods -

extension AddNewAccountVC {
    
    //MARK: addNewAccount
    @objc private func addNewAccount() {
        guard let title = titleTextField.text else { return }
        if title != "" {
            let index = currencyPickerView.selectedRow(inComponent: 0)
            let currency = Currency.allCases[index]
            let newAccount = Account(title: title, currency: currency)
            
            delegate?.addNewAccount(account: newAccount)
            dismiss(animated: true)
        } else {
            let center = titleTextField.center
            let animation = createViewShakeAnimation(center: center)
            titleTextField.layer.add(animation, forKey: "transform.move.x")
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    //MARK: keyboardWillShow
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomConstraint.constant = -keyboardHeight - 20
        bottomConstraint.isActive = true
    }
    
    //MARK: keyboardWillHide
    @objc private func keyboardWillHide() {
        bottomConstraint.isActive = false
    }
}
