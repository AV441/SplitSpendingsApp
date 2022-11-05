//
//  HistoryViewController.swift
//  SplitSpendings
//
//  Created by Андрей on 09.10.2022.
//

import UIKit

fileprivate struct Section {
    var title: String
    var expenses: [GeneralExpense]
}

fileprivate enum SortingType {
    case dateAscending, dateDescending
}

/// Это должно быть внутри `HistoryVC`
fileprivate var sections = [Section]()
fileprivate var sortingType: SortingType = .dateDescending

class HistoryVC: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        return tableView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Вы пока ничего не потратили"
        label.font = .systemFont(ofSize: 24, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        
        switch accounts.isEmpty || accounts[indexOfCurrentAccount].expenses.isEmpty {
        case true:
            configureView()
        case false:
            configureTableView()
            updateTableView()
        }
    }
    
    //MARK: configureNavigationBar
    private func configureNavigationBar() {
        let menuItems: [UIAction] = [
            UIAction(title: "По возрастанию",
                     image: UIImage(systemName: "arrow.up"),
                     handler: { [unowned self] _ in
                         sortingType = .dateAscending
                         updateTableView()
                     }),
            UIAction(title: "По убыванию",
                     image: UIImage(systemName: "arrow.down"),
                     handler: { [unowned self] _ in
                         sortingType = .dateDescending
                         updateTableView()
                     }),
        ]

        let menu = UIMenu(title: "Сортировать по дате",
                          image: nil,
                          identifier: nil,
                          options: [],
                          children: menuItems)
        
        let image = UIImage(systemName: "slider.horizontal.3")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil,
                                                            image: image,
                                                            primaryAction: nil,
                                                            menu: menu)
        
        navigationItem.rightBarButtonItem?.tintColor = .systemYellow
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "История трат"
    }
    
    //MARK: configureView
    private func configureView() {
        view.backgroundColor = .white
        view.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    //MARK: configureTableView
    private func configureTableView() {
        
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
    
    //MARK: updateSections
    private func updateSections() {
        sections.removeAll()
        
        let groupedExpenses = Dictionary(grouping: accounts[indexOfCurrentAccount].expenses,
                                         by: { $0.date.onlyDate })
        
        switch sortingType {
            
        case .dateAscending:
            for (date, expenses) in groupedExpenses.sorted(by: { $0.0 < $1.0 }) {
                let section = Section(title: date.formatted,
                                      expenses: expenses)
                sections.append(section)
            }
            
        case .dateDescending:
            for (date, expenses) in groupedExpenses.sorted(by: { $0.0 > $1.0 }) {
                let section = Section(title: date.formatted,
                                      expenses: expenses)
                sections.append(section)
            }
        }
    }
}

//MARK: - UITableViewDataSource -

extension HistoryVC: UITableViewDataSource {
    
    //MARK: numberOfSections
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    //MARK: titleForHeaderInSection
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    //MARK: numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].expenses.count
    }
    
    //MARK: cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentAccount = accounts[indexOfCurrentAccount]
        let expense = sections[indexPath.section].expenses[indexPath.row]
            
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as! HistoryCell
        
        cell.totalLabel.text = "\(expense.total.formatted()) \(currentAccount.currency.rawValue)"
        
        var names = [String]()
        
        accounts[indexOfCurrentAccount].participants.forEach { person in
            if person.expenses.first(where: { $0.id == expense.id })?.spendings != 0 {
                names.append(person.name)
            } 
        }
        cell.participantsLabel.text = names.joined(separator: ", ")
        cell.detailsLabel.text = expense.details
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    //MARK: heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: - UITableViewDelegate -

extension HistoryVC: UITableViewDelegate {
    
    //MARK: didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let expense = sections[indexPath.section].expenses[indexPath.row]
        
        let VCtoBePresented = AddEditExpenseVC()
        VCtoBePresented.expense = expense
        
        let navigationController = UINavigationController(rootViewController: VCtoBePresented)
        
        present(navigationController, animated: true)
    }
    
    
    //MARK: editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //MARK: commit forRowAt
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let expense = sections[indexPath.section].expenses[indexPath.row]
            accounts[indexOfCurrentAccount].expenses.removeAll(where: { $0.id == expense.id })
            
            for person in accounts[indexOfCurrentAccount].participants {
                if let indexOfPerson = accounts[indexOfCurrentAccount].participants.firstIndex(where: { $0.name == person.name }) {
                    accounts[indexOfCurrentAccount].participants[indexOfPerson].expenses.removeAll(where: { $0.id == expense.id })
                }
            }
            
            updateTableView()
            
            NotificationCenter.default.post(name: personsHasBeenChangedNotification, object: nil)
        }
    }
}

//MARK: - @objc Methods -

extension HistoryVC {
    
    //MARK: updateTableView
    @objc private func updateTableView() {
        updateSections()
        tableView.reloadData()
    }
}
