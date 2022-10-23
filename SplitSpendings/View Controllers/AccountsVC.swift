//
//  AccountsViewController.swift
//  SplitSpendings
//
//  Created by Андрей on 12.10.2022.
//

import UIKit

class AccountsVC: UIViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var collectionView: UICollectionView!

    //MARK: - viewDidLoad -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        setConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(endEditingWhenEntersBackground), name: appHasBeenEnteredBackground, object: nil)
    }
    
    //MARK: - viewWillAppear -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    //MARK: - viewWillDisappear -
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setEditing(false, animated: true)
    }
    
    //MARK: - setEditing -
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.editButtonItem.title = editing ? "Отмена" : "Править"
        
        switch editing {
        case true:
            self.collectionView.isEditing = true
        case false:
            self.collectionView.isEditing = false
        }
        
        if !accounts.isEmpty {
            handleEditing()
        }
    }
    
    //MARK: handleEditing
    private func handleEditing() {
            guard let cell = collectionView.cellForItem(at: IndexPath(item: accounts.count, section: 0)) as? AddNewAccountCell else { return }
        
            switch isEditing {
            case true:
                cell.isUserInteractionEnabled = false
            case false:
                cell.isUserInteractionEnabled = true
            }
           
        let numberOfItems = accounts.count - 1
        for item in 0...numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)
                guard let cell = collectionView.cellForItem(at: indexPath) as? AccountCell else { return }
                
                switch isEditing {
                case true:
                    let itemShakeAnimation = createItemShakeAnimation()
                    cell.deleteButton.isHidden = false
                    cell.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    cell.layer.add(itemShakeAnimation, forKey: "iconShakeAnimation")
                case false:
                    cell.deleteButton.isHidden = true
                    cell.transformChosenCell(account: accounts[indexPath.item])
                    cell.layer.removeAllAnimations()
                }
            }
        }
    
    //MARK: configureNavigationBar
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Совместные счета"
        navigationItem.leftBarButtonItem = editButtonItem
        
        editButtonItem.title = "Править"
        editButtonItem.tintColor = .systemYellow
        changeEditButtonState()
    }
    
    //MARK: changeEditButtonState
    private func changeEditButtonState() {
        if accounts.isEmpty {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
    }
    
    //MARK: configureCollectionView
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: configureLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(AccountCell.self, forCellWithReuseIdentifier: AccountCell.identifier)
        collectionView.register(AddNewAccountCell.self, forCellWithReuseIdentifier: AddNewAccountCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
    }
    //MARK: configureLayout
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        let inset: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(1/2))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: inset,
                                                        leading: inset,
                                                        bottom: inset,
                                                        trailing: inset)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    //MARK: setConstraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - UICollectionViewDataSource -

extension AccountsVC: UICollectionViewDataSource {
    
    //MARK: numberOfItemsInSection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        accounts.count + 1
    }
    
    //MARK: cellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.row {
            
        case accounts.count: //AddNewAccountCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddNewAccountCell.identifier, for: indexPath) as! AddNewAccountCell
            cell.button.addTarget(self, action: #selector(showAddNewAccountVC), for: .touchUpInside)
            return cell
            
        default: //AccountCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountCell.identifier, for: indexPath) as! AccountCell
            cell.configure(account: accounts[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

//MARK: - UICollectionViewDelegate -

extension AccountsVC: UICollectionViewDelegate {
    
    //MARK: didSelectItemAt
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch isEditing {
            
        case true:
            break
            
        case false:
            if indexPath.item < accounts.count {
                indexOfCurrentAccount = indexPath.item
                collectionView.reloadData()
            } else {
                return
            }
        }
    }
}
 
//MARK: @objc Methods

extension AccountsVC {
     
    //MARK: showAddNewAccountVC
    @objc private func showAddNewAccountVC() {
        let VCtoBePresented = AddNewAccountVC()
        VCtoBePresented.delegate = self

        let navController = UINavigationController(rootViewController: VCtoBePresented)
        
        present(navController, animated: true)
    }
}

//MARK: - AddNewAccountVCDelegate -

extension AccountsVC: AddNewAccountVCDelegate {
    
    //MARK: addNewAccount
    func addNewAccount(account: Account) {
        accounts.append(account)
        collectionView.reloadData()
        changeEditButtonState()
    }
}

//MARK: - AccountCellDelegate -

extension AccountsVC: AccountCellDelegate {
    
    //MARK: deleteAccount
    func deleteAccount(sender: AccountCell) {
        guard let indexPath = collectionView.indexPath(for: sender) else { return }
        
        let title = "Удалить \(accounts[indexPath.item].title)?"
        let message = "Удаление счета приведет к потере всех его данных. Вы уверены, что хотите его удалить?"
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Удалить",
                                         style: .destructive) { [unowned self] _ in
            setEditing(false, animated: false)
            accounts.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
            
            switch indexOfCurrentAccount {
            case 0:
                break
            case _ where indexOfCurrentAccount >= indexPath.item:
                indexOfCurrentAccount -= 1
            default:
                break
            }
            
            if !accounts.isEmpty {
                setEditing(true, animated: false)
            }
            
            changeEditButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel)
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    //MARK: endEditingWhenEntersBackground
    @objc func endEditingWhenEntersBackground() {
        setEditing(false, animated: false)
    }
}
