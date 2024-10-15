import UIKit

class TrackerHabbitViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {
    
    // MARK: - UI Elements
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .none
        textField.backgroundColor = .backgroundDayYp

        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always

        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    
    private let optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
        
    }()
    
    private let colorLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Цвет"
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
        
    }()
    
    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 40, height: 40)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let buttonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Кнопка "Создать"
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Кнопка "Отменить"
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let emojis = ["😀", "😺", "🌸", "🐶", "❤️", "😱", "😇", "😡", "🤔", "🥇", "🎸", "🍔"]
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple,
        .systemPink, .systemTeal, .systemIndigo, .systemGray, .brown, .magenta
    ]
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        
        setupViewsWithoutStackView()
    }
    
    // MARK: - Setup Views Without StackView
    private func setupViewsWithoutStackView() {
        // Добавляем элементы на view
        view.addSubview(titleTextField)
        view.addSubview(optionsTableView)
        view.addSubview(emojiCollectionView)
        view.addSubview(colorCollectionView)
        view.addSubview(buttonContainerView)
        view.addSubview(emojiLabel)
        view.addSubview(colorLabel)
        buttonContainerView.addSubview(cancelButton)
        buttonContainerView.addSubview(createButton)
        
        // Устанавливаем констрейнты для каждого элемента
        NSLayoutConstraint.activate([
            // Констрейнты для titleTextField
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            // Констрейнты для optionsTableView
            optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            optionsTableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            
            // Констрейнты для emojiCollectionView
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            emojiCollectionView.widthAnchor.constraint(equalToConstant: 374),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            emojiCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            
            // Констрейнты для colorCollectionView
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 0),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 100),
            
            buttonContainerView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 20),
            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 50),
            
            // Настройки кнопки "Отменить"
            cancelButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor), // Делаем кнопки одинаковой ширины
            
            // Настройки кнопки "Создать"
            createButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            createButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 // Категория и Расписание
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Устанавливаем высоту ячейки
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
        } else {
            cell.textLabel?.text = "Расписание"
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .backgroundDayYp
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath)
            let emojiLabel = UILabel(frame: cell.contentView.bounds)
            emojiLabel.text = emojis[indexPath.item]
            emojiLabel.textAlignment = .center
            emojiLabel.font = .systemFont(ofSize: 32)
            cell.contentView.addSubview(emojiLabel)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            cell.contentView.backgroundColor = colors[indexPath.item]
            cell.contentView.layer.cornerRadius = 8
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
        } else if collectionView == colorCollectionView {
            selectedColor = colors[indexPath.item]
        }
    }
    
    // Метод для задания высоты заголовков
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40) // Высота заголовка
    }

}
