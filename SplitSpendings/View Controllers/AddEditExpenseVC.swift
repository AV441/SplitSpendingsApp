//
//  NewExpenseViewController.swift
//  SplitSpendings
//
//  Created by Андрей on 02.10.2022.
//

import UIKit

enum CellType {
    case totalCell, detailsCell, personalExpenseCell, dateLabelCell, payerLabelCell
}

class AddEditExpenseVC: UIViewController {
    
    var currentAccount = accounts[indexOfCurrentAccount]
    
    var total: Double = 0
    var details: String = ""
    var date: Date = .now
    var payerName: String = accounts[indexOfCurrentAccount].participants[0].name
    var personalSpendings: [String: Double] = [:]
    var sumOfPersonalSpendings: Double = 0
    
    var expense: GeneralExpense?
    
    let totalCellIndexPath = IndexPath(row: 0, section: 0)
    
    let detailCellIndexPath = IndexPath(row: 1, section: 0)
    
    let datePickerLabelIndexPath = IndexPath(row: 0, section: 1)
    let datePickerCellIndexPath = IndexPath(row: 1, section: 1)
    
    let payerPickerLabelIndexPath = IndexPath(row: 0, section: 2)
    let payerPickerCellIndexPath = IndexPath(row: 1, section: 2)
    
    var isSplitEqualy = false
    var isDatePickerVisible = false
    var isPayerPickerVisible = false
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.identifier)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: DatePickerCell.identifier)
        tableView.register(PickerViewCell.self, forCellReuseIdentifier: PickerViewCell.identifier)
        tableView.register(LabelCell.self, forCellReuseIdentifier: LabelCell.identifier)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier)
        
        return tableView
    }()
    
    //MARK: - viewDidLoad -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureTableView()
        setConstraints()
        setGestures()
        addObservers()
        checkIfExpenseIsEditing()
    }
    
    //MARK: configureNavigationBar
    private func configureNavigationBar() {
        navigationItem.title = "Новая покупка"
        
        let leftItem = UIBarButtonItem(title: "Отмена",
                                       style: .plain,
                                       target: self,
                                       action: #selector(cancelView))
        
        let rightItem = UIBarButtonItem(title: "Сохранить",
                                        style: .done,
                                        target: self,
                                        action: #selector(saveChanges))
        
        leftItem.tintColor = .systemRed
        rightItem.tintColor = .systemYellow
        
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
    }
    
    //MARK: configureTableView
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
    }
    
    //MARK: setConstraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    //MARK: setGestures
    private func setGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
    
    //MARK: checkIfExpenseIsEditing
   private func checkIfExpenseIsEditing() {
        if let expense = expense {
            total = expense.total
            details = expense.details
            date = expense.date
            payerName = expense.payer.name
            
            for participant in expense.participants {
                
                guard let personalSpending = participant.expenses.first(where: { $0.id == expense.id } )?.spendings
                else { return }
                personalSpendings.updateValue(personalSpending, forKey: participant.name)
            }
        }
    }
    
    //MARK: splitSpendingsEqualy
    private func splitSpendingsEqualy() {
        let participants = currentAccount.participants
        let numberOfParticipants = currentAccount.participants.count
        
        for row in 1...numberOfParticipants {
            
            let indexPath = IndexPath(row: row, section: 3)
            guard let personalSpendingsCell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
            
            let personalSpending = total / Double(numberOfParticipants)
            personalSpendingsCell.textField.text = String(round(personalSpending * 100) / 100)
            
            personalSpendings.updateValue(personalSpending, forKey: participants[row - 1].name)
        }
    }
    
    //MARK: clearPersonalSpendingsTextFields
    private func clearPersonalSpendingsTextFields() {
        let numberOfParticipants = accounts[indexOfCurrentAccount].participants.count
        
        for row in 1...numberOfParticipants {
            
            let indexPath = IndexPath(row: row, section: 3)
            guard let personalSpendingsCell = tableView.cellForRow(at: indexPath) as? TextFieldCell else { return }
            personalSpendingsCell.textField.text?.removeAll()
        }
    }
    
    //MARK: createDataToBeSaved
    private func createDataToBeSaved() -> (id: UUID, personalExpenses: [PersonalExpense])? {
        sumOfPersonalSpendings = 0
        
        let newExpenseID = UUID()
        
        var personalExpenses = [PersonalExpense]()
        
        for participant in currentAccount.participants {

            var personalPayment: Double = 0
            
            if participant.name == self.payerName {
                personalPayment = self.total
            } else {
                personalPayment = 0
            }

            guard let personalSpending = personalSpendings[participant.name] else { return nil }
            self.sumOfPersonalSpendings += personalSpending
            
            let personalExpense = PersonalExpense(spendings: personalSpending,
                                                  payments: personalPayment,
                                                  details: self.details,
                                                  date: self.date,
                                                  id: newExpenseID)
            
            personalExpenses.append(personalExpense)
        }
        
        return (newExpenseID, personalExpenses)
    }
    
    //MARK: addNewData
    private func addNewData(_ id: UUID, _ personalExpenses: [PersonalExpense]) {
        
        for indexOfParticipant in 0..<personalExpenses.count {
            
            accounts[indexOfCurrentAccount].participants[indexOfParticipant].expenses.append(personalExpenses[indexOfParticipant])
        }
        
        let payer = accounts[indexOfCurrentAccount].participants.first(where: { $0.name == payerName })
        
        let generalExpense = GeneralExpense(total: self.total,
                                            details: self.details,
                                            date: self.date,
                                            payer: payer ?? accounts[indexOfCurrentAccount].participants[0],
                                            participants: accounts[indexOfCurrentAccount].participants,
                                            id: id)
        
        accounts[indexOfCurrentAccount].expenses.append(generalExpense)
                
        NotificationCenter.default.post(name: personsHasBeenChangedNotification, object: nil)
        
        dismiss(animated: true)
    }
    
    //MARK: saveChangedData
    private func saveChangedData(_ id: UUID, _ personalExpenses: [PersonalExpense]) {
        guard let expense = expense else { return }
        
        for indexOfParticipant in 0..<personalExpenses.count {
            
            if let indexOfPersonalExpense = currentAccount.participants[indexOfParticipant].expenses.firstIndex(where: { $0.id == expense.id }) {
                
                accounts[indexOfCurrentAccount].participants[indexOfParticipant].expenses[indexOfPersonalExpense] = personalExpenses[indexOfParticipant]
            }
        }
        
        let payer = accounts[indexOfCurrentAccount].participants.first(where: { $0.name == payerName })
        
        let generalExpense = GeneralExpense(total: self.total,
                                            details: self.details,
                                            date: self.date,
                                            payer: payer ?? accounts[indexOfCurrentAccount].participants[0],
                                            participants: accounts[indexOfCurrentAccount].participants,
                                            id: id)
        
        if let indexOfGeneralExpense = accounts[indexOfCurrentAccount].expenses.firstIndex(where: { $0.id == expense.id }) {
            
            accounts[indexOfCurrentAccount].expenses[indexOfGeneralExpense] = generalExpense
        }
        
        NotificationCenter.default.post(name: personsHasBeenChangedNotification, object: nil)
        
        dismiss(animated: true)
    }
    
    //MARK: createAlert
    private func createAlert(title: String) {
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ок", style: .cancel)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
}

//MARK: - UITableViewDataSource -

extension AddEditExpenseVC: UITableViewDataSource {
    
    //MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    //MARK: titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: //Expense section
            return "Описание покупки"
        case 1: //DatePicker section
            return "Дата покупки"
        case 2: //PayerPicker section
            return "Кто оплатил"
        case 3: //Participants section
            return "Распределение между участниками"
        default:
            return nil
        }
    }
    
    //MARK: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: //Expense section
            return 2
        case 1: //DatePicker section
            return 2
        case 2: //PayerPicker section
            return 2
        default: //Participants section
            let numberOfParticipantsInCurrentAccount = accounts[indexOfCurrentAccount].participants.count
            return numberOfParticipantsInCurrentAccount + 1
        }
    }
    
    //MARK: cellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
            //MARK: Expense section
        case 0:
            switch indexPath.row {
                
                //Total Cell
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
                cell.configure(.totalCell, with: expense, for: indexPath)
                cell.textField.addTarget(self, action: #selector(totalValueChanged(textfield:)), for: .editingChanged)
                cell.textField.delegate = self
                return cell
                
                //Details Cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
                cell.configure(.detailsCell, with: expense, for: indexPath)
                cell.textField.addTarget(self, action: #selector(detailsChanged(textfield:)), for: .editingChanged)
                cell.textField.delegate = self
                return cell
            default: fatalError()
            }
            
            //MARK: DatePicker section
        case 1:
            switch indexPath.row {
                
                //DateLabel Cell
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                cell.configure(.dateLabelCell, with: expense)
                return cell
                
                //Expandable DatePicker Cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: DatePickerCell.identifier, for: indexPath) as! DatePickerCell
                cell.datePicker.addTarget(self, action: #selector(updateDateLabel), for: .valueChanged)
 
                if let expense = expense {
                    cell.datePicker.date = expense.date
                }
                return cell
            default: fatalError()
            }
            
            //MARK: PayerPicker section
        case 2:
            switch indexPath.row {
                
                //PayerLabel Cell
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: LabelCell.identifier, for: indexPath) as! LabelCell
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                cell.configure(.payerLabelCell, with: expense)
                return cell
                
                //Expandable PayerPicker Cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: PickerViewCell.identifier, for: indexPath) as! PickerViewCell
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                
                if let expense = expense {
                    if let indexOfPayer = accounts[indexOfCurrentAccount].participants.firstIndex(where: { $0.name == expense.payer.name }) {
                        cell.pickerView.selectRow(indexOfPayer, inComponent: 0, animated: false)
                    }
                }
                return cell
            default: fatalError()
            }
            
            //MARK: Participants section
        case 3:
            switch indexPath.row {
                
                //SplitEqualyButton Cell
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier, for: indexPath) as! ButtonCell
                cell.button.addTarget(self, action: #selector(splitEqualyButtonPressed), for: .touchUpInside)
                return cell
                
                //Participants spendings Cells
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as! TextFieldCell
                cell.configure(.personalExpenseCell, with: expense, for: indexPath)
                
                if let savedSpending = personalSpendings[currentAccount.participants[indexPath.row - 1].name] {
                    cell.textField.text = String(savedSpending)
                    print(savedSpending)
                }
                
                cell.textField.tag = indexPath.row - 1
                cell.textField.addTarget(self, action: #selector(participantsSpendingsChanged(textField:)), for: .editingChanged)
                cell.textField.delegate = self
                return cell
            }
            
        default:
           fatalError()
        }
    }
}

//MARK: - UITableViewDelegate -

extension AddEditExpenseVC: UITableViewDelegate {
    
    //MARK: heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerCellIndexPath:
            return isDatePickerVisible ? 216 : 0
        case payerPickerCellIndexPath:
            return isPayerPickerVisible ? 216 : 0
        default:
            return 44
        }
    }
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
            if indexPath == datePickerLabelIndexPath {
                isDatePickerVisible.toggle()
                tableView.reloadRows(at: [datePickerCellIndexPath], with: .automatic)
            }
            
            if indexPath == payerPickerLabelIndexPath {
                isPayerPickerVisible.toggle()
                tableView.reloadRows(at: [payerPickerCellIndexPath], with: .automatic)
            }
    }
}

//MARK: - UIPickerViewDataSource -

extension AddEditExpenseVC: UIPickerViewDataSource {
    
    //MARK: numberOfComponents
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //MARK: numberOfRowsInComponent
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return accounts[indexOfCurrentAccount].participants.count
    }
    
    //MARK: titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accounts[indexOfCurrentAccount].participants[row].name
    }
}

//MARK: - UIPickerViewDelegate -

extension AddEditExpenseVC: UIPickerViewDelegate {
    
    //MARK: didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        payerName = currentAccount.participants[row].name
        
        guard let cell = tableView.cellForRow(at: payerPickerLabelIndexPath) as? LabelCell else { return }
        cell.label.text = payerName
    }
}

//MARK: - UITextFieldDelegate -

extension AddEditExpenseVC: UITextFieldDelegate {
    
    //MARK: textFieldShouldReturn
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}

//MARK: - @objc methods -

extension AddEditExpenseVC {
    
    //MARK: hideKeyboard
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: keyboardWillShow
    ///Add inset to tableView when keyboard appears
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 20, right: 0)
    }
    
    //MARK: keyboardWillHide
    ///Remove inset from tableView when keyboard hides
    @objc private func keyboardWillHide() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }
    
    //MARK: updateDateLabel
    ///Update DateLabel if new date has been picked
    @objc private func updateDateLabel(_ datePicker: UIDatePicker) {
        guard let cell = tableView.cellForRow(at: datePickerLabelIndexPath) as? LabelCell else { return }
        cell.label.text = datePicker.date.formatted
        self.date = datePicker.date
    }
    
    //MARK: splitEqualyButtonPressed
    ///Handle split equaly button press
    @objc private func splitEqualyButtonPressed() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as? ButtonCell else { return }
        
        isSplitEqualy.toggle()
        
        switch isSplitEqualy {
        case true:
            let image = UIImage(systemName: "checkmark.square")
            cell.button.setImage(image, for: .normal)
            splitSpendingsEqualy()
        case false:
            let image = UIImage(systemName: "square")
            cell.button.setImage(image, for: .normal)
            clearPersonalSpendingsTextFields()
        }
    }
    
    //MARK: cancelView
    @objc private func cancelView() {
        dismiss(animated: true)
    }
    
    //MARK: saveChanges
    @objc private func saveChanges() {
        
        if personalSpendings.isEmpty {
            createAlert(title: "Заполните распределение между участниками")

        } else if details == "" {
            createAlert(title: "Добавьте описание")
            
        } else {
            
            guard let data = createDataToBeSaved() else { return }
            
            switch total {
            case .zero:
                createAlert(title: "Cумма покупки должна быть больше нуля")
                
            case _ where total != sumOfPersonalSpendings:
                print(total, sumOfPersonalSpendings)
                createAlert(title: "Общая сумма покупки не соответствует сумме затрат всех участников")
                
            default:
                switch expense {
                case .none:
                    addNewData(data.id, data.personalExpenses)
                case .some(_):
                    saveChangedData(data.id, data.personalExpenses)
                }
            }
        }
    }
}


extension AddEditExpenseVC {
    
    @objc func totalValueChanged(textfield: UITextField) {
        let value = textfield.value
        self.total = value
    }
    
    @objc func detailsChanged(textfield: UITextField) {
        guard let details = textfield.text else { return }
        self.details = details
    }
    
    @objc func participantsSpendingsChanged(textField: UITextField) {
        
        let personalSpending = textField.value
        let indexOfParticipant = textField.tag
        let participants = accounts[indexOfCurrentAccount].participants
        let name = participants[indexOfParticipant].name
        
        personalSpendings.updateValue(personalSpending, forKey: name)
    }
}
