//
//  MainViewController.swift
//  SplitSpendings
//
//  Created by Андрей on 30.09.2022.
//

import UIKit

class BalancesVC: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PersonCell.self, forCellReuseIdentifier: PersonCell.identifier)
        tableView.register(AddPersonCell.self, forCellReuseIdentifier: AddPersonCell.identifier)
        tableView.allowsSelection = false
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы пока не создали ни один счет"
        label.font = .systemFont(ofSize: 24, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let rightButton = UIButton(type: .system)
    let leftButton = UIButton(type: .system)
    
    //MARK: - viewDidLoad -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView), name: personsHasBeenChangedNotification, object: nil)
    }
    
    //MARK: - viewWillAppear -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.removeFromSuperview()
        
        switch accounts.isEmpty {
        case true:
            configureView()
            changeBarButtonsStatus()
        case false:
            configureTableView()
            tableView.reloadData()
            changeBarButtonsStatus()
        }
    }
    
    //MARK: configureNavigationBar
    private func configureNavigationBar() {
        
        rightButton.setImage(UIImage(systemName: "plus"), for: .normal)
        rightButton.tintColor = .systemYellow
        rightButton.addTarget(self, action: #selector(showAddEditExpenseVC), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: rightButton)
        
        leftButton.setTitle("Изменить", for: .normal)
        leftButton.tintColor = .systemYellow
        leftButton.addTarget(self, action: #selector(changeAccountTitle), for: .touchUpInside)
        let leftItem = UIBarButtonItem(customView: leftButton)
        
        navigationItem.leftBarButtonItem = leftItem
        navigationItem.rightBarButtonItem = rightItem
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func changeBarButtonsStatus() {
        guard let leftButton = navigationItem.leftBarButtonItem,
              let rightButton = navigationItem.rightBarButtonItem else { return }
        
        switch accounts.isEmpty {
        case true:
            leftButton.isEnabled = false
            rightButton.isEnabled = false
        case false:
            leftButton.isEnabled = true
            let currentAccount = accounts[indexOfCurrentAccount]
            if !currentAccount.participants.isEmpty {
                rightButton.isEnabled = true
            } else {
                rightButton.isEnabled = false
            }
        }
    }
    
    //MARK: configureView
    private func configureView() {
        navigationItem.title = "Текущий счет"
        view.backgroundColor = .white
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: configureTableView
    private func configureTableView() {
        navigationItem.title = accounts[indexOfCurrentAccount].title
        
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - UITableViewDataSource -

extension BalancesVC: UITableViewDataSource {
    
    //MARK: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfParticipantsInCurrentAccount = accounts[indexOfCurrentAccount].participants.count
        return numberOfParticipantsInCurrentAccount + 1
    }
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfParticipantsInCurrentAccount = accounts[indexOfCurrentAccount].participants.count
        
        switch indexPath.row {
            
        //AddPersonCell
        case numberOfParticipantsInCurrentAccount:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPersonCell.identifier, for: indexPath) as! AddPersonCell
            cell.button.addTarget(self, action: #selector(addPerson), for: .touchUpInside)
            return cell
            
        //PersonCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: PersonCell.identifier, for: indexPath) as! PersonCell
            let currentAccount = accounts[indexOfCurrentAccount]
            let person = currentAccount.participants[indexPath.row]
            cell.configure(person: person)
            return cell
        }
    }
    
    //MARK: heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case accounts[indexOfCurrentAccount].participants.count:
            return 60
        default:
            return 90
        }
    }
}

//MARK: - UITableViewDelegate -

extension BalancesVC: UITableViewDelegate {
    
    //MARK: editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //MARK: commit forRowAt
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if accounts[indexOfCurrentAccount].participants[indexPath.row].expenses.isEmpty {
                accounts[indexOfCurrentAccount].participants.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                changeBarButtonsStatus()
            } else {
                let alert = UIAlertController(title: "Нельзя удалить данного участника",
                                              message: "Удаление участника приведет к ошибкам в расчетах, т.к. у него имеются текущие расходы",
                                              preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Ок", style: .cancel)
                
                alert.addAction(cancelAction)
                present(alert, animated: true)
            }
        }
    }
}

//MARK: - @objc methods -

extension BalancesVC {
    
    //MARK: addPerson
    @objc private func addPerson() {
        let alertController = UIAlertController(title: "Добавить участника",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?[0].placeholder = "Имя"
        
        let submitAction = UIAlertAction(title: "Добавить",
                                         style: .default) { [unowned self] _ in
            guard let name = alertController.textFields?[0].text else { return }
            
            if name.isEmpty {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                alertController.message = "Имя не должно быть пустым!"
                present(alertController, animated: true)
            } else {
                let person = Person(name: name)
                accounts[indexOfCurrentAccount].participants.append(person)
                updateTableView()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    //MARK: showAddEditExpenseVC
    @objc private func showAddEditExpenseVC() {
        let destinationVC = AddEditExpenseVC()
        let navController = UINavigationController(rootViewController: destinationVC)
        present(navController, animated: true)
    }
    
    //MARK: updateTableView
    @objc private func updateTableView() {
        tableView.reloadData()
        changeBarButtonsStatus()
    }
    
    //MARK: changeAccountTitle
    @objc private func changeAccountTitle() {
        let alertController = UIAlertController(title: "Изменить название счета",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addTextField()
        alertController.textFields?[0].text = accounts[indexOfCurrentAccount].title
        
        let submitAction = UIAlertAction(title: "Сохранить",
                                         style: .default) { [unowned self] _ in
            
            guard let newTitle = alertController.textFields?[0].text else { return }
            
            if newTitle.isEmpty {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
                alertController.message = "Назавание не должно быть пустым!"
                present(alertController, animated: true)
            } else {
                accounts[indexOfCurrentAccount].title = newTitle
                navigationItem.title = newTitle
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
