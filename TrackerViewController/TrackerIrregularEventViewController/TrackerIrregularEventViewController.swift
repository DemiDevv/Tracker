import UIKit

class TrackerIrregularEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Elements
    private let irRegularTitle: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16)
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    
    private let optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true  // Закругление углов таблицы
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = .zero  // Убираем внутренние отступы для разделителей
        tableView.separatorColor = .lightGray  // Цвет разделителей
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
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
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
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojis = ["😀", "😺", "🌸", "🐶", "❤️", "😱", "😇", "😡", "🤔", "🥇", "🎸", "🍔", "😺", "🌸", "🐶", "❤️", "😱", "😇"]
    private let colors: [UIColor] = [
        .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple,
        .systemPink, .systemTeal, .systemIndigo, .systemGray, .brown, .magenta, .systemRed, .systemOrange, .systemYellow, .systemGreen, .systemBlue, .systemPurple
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
        optionsTableView.tableFooterView = UIView()
        
        setupViewsWithoutStackView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCollectionViewHeights()
    }

    func updateCollectionViewHeights() {
        let itemHeight: CGFloat = 52
        let numberOfRows: CGFloat = 3
        let totalHeight = itemHeight * numberOfRows + 24 * 2
        
        emojiCollectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: totalHeight).isActive = true
    }
    
    @objc private func textFieldDidChange() {
        if let text = titleTextField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .blackDayYp
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .grayYp
        }
    }
    
    @objc private func didTapCancelButton() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapCreateButton() {
        guard let title = titleTextField.text, !title.isEmpty
//              let selectedEmoji = selectedEmoji,
//              let selectedColor = selectedColor
        else {
            return
        }

        let currentDate = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)

        guard let selectedWeekday = Weekday(rawValue: weekday) else {
            return
        }
        
        let newTracker = Tracker(id: UUID(), title: title, color: .colorSelection1, emoji: "😀", schedule: [])

        NotificationCenter.default.post(name: .didCreateNewTracker, object: newTracker)
        
        print("Создаю трекер с title: \(title), emoji: \("😀"), schedule: \(newTracker.schedule)")

        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func setupViewsWithoutStackView() {
        // Добавляем фиксированные элементы на основной view
        view.addSubview(irRegularTitle)
        view.addSubview(titleTextField)
        view.addSubview(optionsTableView)
        
        // Настраиваем scrollView для скроллируемой части
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        // Добавляем элементы в scrollContentView (только скроллируемые части)
        scrollContentView.addSubview(emojiLabel)
        scrollContentView.addSubview(emojiCollectionView)
        scrollContentView.addSubview(colorLabel)
        scrollContentView.addSubview(colorCollectionView)
        
        // Добавляем кнопки на основной view
        view.addSubview(buttonContainerView)
        buttonContainerView.addSubview(cancelButton)
        buttonContainerView.addSubview(createButton)
        
        // Констрейнты для фиксированных элементов
        NSLayoutConstraint.activate([
            irRegularTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            irRegularTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: irRegularTitle.bottomAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        // Констрейнты для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 16),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor)
        ])
        
        // Констрейнты для scrollContentView
        NSLayoutConstraint.activate([
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Обеспечиваем горизонтальный скроллинг
        ])
        
        // Констрейнты для скроллируемых элементов
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 16),  // Отступ 16
            emojiLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),  // Отступ 16
            colorLabel.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 28),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 8),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -16),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor, constant: -16)
        ])
        
        // Констрейнты для кнопок
        NSLayoutConstraint.activate([
            // Констрейнты для `buttonContainerView`
            buttonContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 66), // Увеличиваем высоту на 16 (50 + 16)
            
            // Констрейнты для `cancelButton`
            cancelButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            cancelButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 16), // Отступ от верхнего края контейнера
            cancelButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            // Констрейнты для `createButton`
            createButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            createButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 16), // Отступ от верхнего края контейнера
            createButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor)
        ])
        
        // Настройка делегатов и источников данных
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }

    // MARK: - UITableViewDataSource
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Категория и Расписание
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Устанавливаем высоту ячейки
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        cell.textLabel?.text = "Категория"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .backgroundDayYp
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // Убираем разделитель для последней ячейки
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            // Восстанавливаем стандартный разделитель для остальных ячеек
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let scheduleVC = ScheduleViewController()
            scheduleVC.modalPresentationStyle = .pageSheet
            present(scheduleVC, animated: true, completion: nil)

        }
    }
    
    // Убираем отступы между секциями и ячейками
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0 // Убираем отступы перед секцией
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0 // Убираем отступы после секции
    }
    
    // Убираем отступы между ячейками
    func tableView(_ tableView: UITableView, layoutMarginsForItemAt indexPath: IndexPath) -> UIEdgeInsets {
        return UIEdgeInsets.zero // Минимизируем отступы между ячейками
    }
    
}


extension TrackerIrregularEventViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == emojiCollectionView {
            return emojis.count
        } else if collectionView == colorCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! TrackerHabbitViewCell
            cell.titleLabel.text = emojis[indexPath.row]
            cell.colorView.isHidden = true // Скрываем colorView для Emoji ячейки
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! TrackerHabbitViewCell
            cell.colorView.backgroundColor = colors[indexPath.row]
            cell.titleLabel.isHidden = true // Скрываем текстовую метку для Color ячейки
            cell.colorView.isHidden = false
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TrackerIrregularEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}


extension TrackerIrregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemsPerRow: CGFloat = 6 // Количество столбцов
        let paddingSpace: CGFloat = 18 * 2 + (5 * (itemsPerRow - 1)) // Отступы с краев и между ячейками
        let availableWidth = collectionView.bounds.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem) // Квадратная ячейка
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5 // Отступ между столбцами
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5 // Отступ между строками
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Отступы вокруг коллекции
    }
}


