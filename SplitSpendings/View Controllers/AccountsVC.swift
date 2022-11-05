//
//  AccountsViewController.swift
//  SplitSpendings
//
//  Created by Андрей on 12.10.2022.
//

import UIKit

/// Лучше чуть менять структуру проекта. В данный момент у тебя все разделено на группы:
/// - контроллеры
/// - ячейки
/// Когда ты снимешь часть нагрузки с контроллером, появятся новые сущности.
/// Лучше делить по назначению модулей, например:
/// - AccountVC, AccountCell и тд;
/// - BalanceVC, все ячейки этого контроллера и тд
/// - То, что используется в нескольких местах, можно выносить в какую-нибудь папку CommonCells и тд



/// Если не планируется создавать наследников класса, то нужно использовать при объявлении `final`
/// Т.е `final class AccountVC` это влият на диспетчеризацию методов
class AccountsVC: UIViewController {

    deinit {
        /// Если я не ошибаюсь, то отписываться от получения нотификаций уже не нужно.
        NotificationCenter.default.removeObserver(self)
    }

    /// Это свойство не должно быть `private`?
    var collectionView: UICollectionView!

    /// Писать MARK перед каждым методом не надо. Эта дирректива позволяет легче ориенториваться в микрокарте файла (верхнаяя панель, справа от открытых файлов средняя вкладка -> minimap)
    /// MARK стоит использовать перед `extionsion`ами, для группировки методов по назначению

    /// Т.е. напирмер, для первых трех методов можно написать только один
    /// MARK: - Методы жизненного цикла

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

        /// Тут ты что-то напутал, тк можно просто
        /// `collectionView.isEditing = editing`

        switch editing {
        case true:
            /// Не нужно писать `self.` когда в этом нет необходимости
            self.collectionView.isEditing = true
        case false:
            self.collectionView.isEditing = false
        }


        /// `accounts` не объявлен в интерфейсе `AccountsVC`. Это называется неявная зависимость. (в некотором роде)
        /// В контроллера должно быть свойство `private var accountStorage`, через которое ты работаешь с аккаунтами.
        if !accounts.isEmpty {
            handleEditing()
        }
    }
    
    //MARK: handleEditing
    private func handleEditing() {
        /// Тут что-то не так с отступами

        /// 1) Если я правильно понял, то тут ты блокируешь нажатия на кнопку внутри ячейки добавления новой записи.
        /// Если коротко: так делать не надо. Обаботка нажатия должны быть в одном из двух мест, в зависимости от реализации:
        /// - в `func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)`
        /// - через делегат
        ///
        /// 2) У данного `guard` есть проблема: если ячейка добавления не будет найдена, то другие ячейки не изменят своё состояние, тк произойдет выход их метода через `return` в `guard`
            guard let cell = collectionView.cellForItem(at: IndexPath(item: accounts.count, section: 0)) as? AddNewAccountCell else { return }

        /// `cell.isUserInteractionEnabled = !isEditing`
            switch isEditing {
            case true:
                cell.isUserInteractionEnabled = false
            case false:
                cell.isUserInteractionEnabled = true
            }

        /// `ViewController` не должен знать ничего о внутренностях ячеек, с которыми он работает.
        /// Общение должно происходить через некий интерфейс ячейки.

        /// Попробуй у брать весь код в `switch`, добавим ячейке методы `startShaking / stopShaking`
        let numberOfItems = accounts.count - 1
        for item in 0...numberOfItems {
                let indexPath = IndexPath(item: item, section: 0)

                /// Тут лишняя работа: представь, что у тебя 1000 аккаунтов. Таблица / коллекция создаёт только то кол-во ячеек, которые отображаются на экране (+ еще пару). Т.е 8-9 штук.
                /// Тут ты принудительно заставляешь ее создать все 1000, хотя их даже не видно.

                /// Решения:
                /// - использовать `visibleCells`
                /// - перенести установку анимации в `cellForItemAtIndexPath` + перезагружать нужные ячейки при необходимости
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
        /// Можно проще: `editButtonItem.isEnabled = !accounts.isEmty`
        /// Или более читаемый вариант, если работаешь в команде
        /// ```
        /// let canEditAccounts = !accounts.isEmpty
        /// editButtonItem.isEditable = canEditAccounts
        /// ```
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
        /// Ты очень много используешь `switch`, тут он не нужен
        /// 1)
        /// ```
        /// if indexPath.row == accounts.count {
        ///     AddNewAccountCell
        /// } else {
        ///     AccountCell
        /// }
        /// ```
        /// Или
        /// ```
        /// guard indexPath.row != accounts.count else {
        ///     AddNewAccountCell
        /// }
        ///
        ///AccountCell
        /// ```
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
        /// ```
        /// guard !isEditing,
        ///       indexPath.item < accounts.count
        /// else { return }
        ///
        /// indexOfCurrentAccount = indexPath.item
        ///
        /// ```
        switch isEditing {
            
        case true:
            break
            
        case false:
            if indexPath.item < accounts.count {
                indexOfCurrentAccount = indexPath.item
                /// Не нужно перезагружать всю коллекцию, достаточно перезагрузить ячейки по старому и новому индексу
                /// `reloadData` стоит вызывать в минимальном кол-ве сценариев. Например, когда произошло полное изменение данных
                collectionView.reloadData()
            } else {
                return
            }
        }
    }
}
 
//MARK: @objc Methods

/// Этот `extionsion` долджен быть `private`, и соотв модификатор видимости для методов писать не надо
extension AccountsVC {
     
    //MARK: showAddNewAccountVC
    /// Это называется роутинг. (Переход в другой котнроллер)
    /// Почитай, например, про Router в VIPER. В идеале, этим должна заниматься другая сущность, не `ViewController`
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
