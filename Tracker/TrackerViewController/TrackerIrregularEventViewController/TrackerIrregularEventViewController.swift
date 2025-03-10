import UIKit

final class TrackerIrregularEventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UI Elements
    private lazy var irRegularTitle: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16)
        label.tintColor = Colors.fontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = PaddedTextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название трекера"
        textField.borderStyle = .none
        textField.backgroundColor = Colors.tableCellColor
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    // Метка для отображения максимального количества символов
    private lazy var maxLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .redYp
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private lazy var optionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true  // Закругление углов таблицы
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Colors.tableCellColor
        tableView.separatorInset = .zero  // Убираем внутренние отступы для разделителей
        tableView.separatorColor = .lightGray  // Цвет разделителей
        return tableView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.tintColor = Colors.fontColor
        return emojiLabel
        
    }()
    
    private lazy var colorLabel: UILabel = {
        let colorLabel = UILabel()
        colorLabel.text = "Цвет"
        colorLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        colorLabel.tintColor = Colors.fontColor
        return colorLabel
        
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = Colors.viewBackground
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerHabbitViewCell.self, forCellWithReuseIdentifier: "ColorCell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = Colors.viewBackground
        return collectionView
    }()
    
    private lazy var buttonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Кнопка "Создать"
    private lazy var createButton: UIButton = {
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
    private lazy var cancelButton: UIButton = {
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
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
        return tapGesture
    }()
    
    weak var trackerHabbitDelegate: TrackerHabbitViewControllerDelegate?
    private var optionsTableViewTopConstraint: NSLayoutConstraint!
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var category: TrackerCategory?
    private var isEditMode = false
    private var trackerToEdit: Tracker? // Трекер для редактирования
    private var daysCount: Int = 0 // Количество дней для отображения
    
    // MARK: - Init
    
    // Инициализатор для создания нового трекера
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    // Инициализатор для редактирования существующего трекера
    init(trackerToEdit: Tracker, category: TrackerCategory?) {
        self.trackerToEdit = trackerToEdit
        self.category = category
        self.isEditMode = true
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.viewBackground
        view.addGestureRecognizer(tapGesture)
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        optionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "optionCell")
        optionsTableView.tableFooterView = UIView()

        setupViewsWithoutStackView()

        if isEditMode {
            setDataToEdit()
        }

        emojiCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        colorCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true

        updateCollectionViewHeights()
    }

    @objc
    private func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateCollectionViewHeights() {
        let itemHeight: CGFloat = 52 // Высота одной ячейки
        let itemsPerRow: CGFloat = 6 // Количество столбцов
        let interItemSpacing: CGFloat = 5 // Отступ между элементами

        // Определяем количество строк
        let emojiRows = ceil(CGFloat(Constants.emojis.count) / itemsPerRow)
        let colorRows = ceil(CGFloat(Constants.colors.count) / itemsPerRow)
        
        // Рассчитываем итоговую высоту коллекции
        let emojiHeight = emojiRows * itemHeight + max(emojiRows - 1, 0) * interItemSpacing
        let colorHeight = colorRows * itemHeight + max(colorRows - 1, 0) * interItemSpacing
        
        // Устанавливаем высоты
        emojiCollectionView.heightAnchor.constraint(equalToConstant: emojiHeight).isActive = true
        colorCollectionView.heightAnchor.constraint(equalToConstant: colorHeight).isActive = true
    }
    
    @objc private func textFieldDidChange() {
        guard let text = titleTextField.text else { return }

        let isTextEmpty = text.isEmpty
        let isOverLimit = text.count > 38

        maxLengthLabel.isHidden = !isOverLimit
        createButton.isEnabled = !isTextEmpty && !isOverLimit

        if isOverLimit || isTextEmpty {
            createButton.backgroundColor = .grayYp
            createButton.setTitleColor(.white, for: .normal)
        } else {
            createButton.backgroundColor = Colors.buttonDisabledColor
            createButton.setTitleColor(Colors.viewBackground, for: .normal)
        }

        optionsTableViewTopConstraint?.constant = isOverLimit ? 62 : 24

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didTapCancelButton() {
        presentingViewController?.dismiss(animated: true, completion: nil)
        trackerHabbitDelegate?.didTapCancelButton()
    }
    
    @objc private func didTapCreateButton() {
        guard
            let category = category?.title,
            let title = titleTextField.text, !title.isEmpty,
            let color = selectedColor,
            let emoji = selectedEmoji
        else { return }

        let tracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            title: title,
            color: color,
            emoji: emoji,
            schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday],
            type: .event ,
            isPinned: trackerToEdit?.isPinned ?? false
        )

        if isEditMode {
            trackerHabbitDelegate?.didTapSaveButton(categoryTitle: category, trackerToUpdate: tracker)
        } else {
            trackerHabbitDelegate?.didTapCreateButton(categoryTitle: category, trackerToAdd: tracker)
        }

        presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Setup Data for Editing

    private func setDataToEdit() {
        guard let tracker = trackerToEdit else { return }

        titleTextField.text = tracker.title
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color

        if let index = Constants.emojis.firstIndex(of: tracker.emoji) {
            let indexPath = IndexPath(row: index, section: 0)
            emojiCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }

        if let index = Constants.colors.firstIndex(of: tracker.color) {
            let indexPath = IndexPath(row: index, section: 0)
            colorCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        }

        optionsTableView.reloadData()
        createButton.setTitle("Сохранить", for: .normal)
        createButton.backgroundColor = Colors.buttonDisabledColor
        irRegularTitle.text = "Редактирование нерегулярного события"
    }

    private func setupViewsWithoutStackView() {
        // Добавляем фиксированные элементы на основной view
        view.addSubview(irRegularTitle)
        view.addSubview(titleTextField)
        view.addSubview(maxLengthLabel)
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
        
        optionsTableViewTopConstraint = optionsTableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24)
        optionsTableViewTopConstraint.isActive = true
        
        // Констрейнты для фиксированных элементов
        NSLayoutConstraint.activate([
            irRegularTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            irRegularTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: irRegularTitle.bottomAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            maxLengthLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            maxLengthLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            maxLengthLabel.heightAnchor.constraint(equalToConstant: 22),
            
            // Устанавливаем констрейнт с сохранением ссылки
            optionsTableViewTopConstraint,
            optionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsTableView.heightAnchor.constraint(equalToConstant: 75)
        ])
        
        // Констрейнты для scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: optionsTableView.bottomAnchor, constant: 32),
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
            emojiLabel.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 0),
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
        
        emojiCollectionView.allowsMultipleSelection = false
        colorCollectionView.allowsMultipleSelection = false
    }

    // MARK: - UITableViewDataSource
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 // Категория и Расписание
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 // Устанавливаем высоту ячейки
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "optionCell")
        
        cell.textLabel?.text = "Категория"
        cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = category?.title
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = .grayYp
        cell.backgroundColor = Colors.tableCellColor
        
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
        
        if indexPath.row == 0 {
            let categoryViewController = CategoryViewController(
                selectedCategory: category,
                delegate: self
            )

            let navigationController = UINavigationController(rootViewController: categoryViewController)
            present(navigationController, animated: true)
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
            return Constants.emojis.count
        } else if collectionView == colorCollectionView {
            return Constants.colors.count
        }
        return 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? TrackerHabbitViewCell else {
                return UICollectionViewCell()
            }
            cell.titleLabel.text = Constants.emojis[indexPath.row]
            cell.colorView.isHidden = true // Скрываем colorView для Emoji ячейки
            return cell
        } else if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? TrackerHabbitViewCell else {
                return UICollectionViewCell()
            }
            cell.innerColorView.backgroundColor = Constants.colors[indexPath.row]
            cell.titleLabel.isHidden = true // Скрываем текстовую метку для Color ячейки
            cell.colorView.isHidden = false
            return cell
        }
        return UICollectionViewCell()
    }
}

extension TrackerIrregularEventViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerHabbitViewCell else { return }
        
        cell.isSelected = true
        
        if collectionView == emojiCollectionView {
            selectedEmoji = Constants.emojis[indexPath.row]
        } else if collectionView == colorCollectionView {
            selectedColor = Constants.colors[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerHabbitViewCell else { return }
        cell.isSelected = false
    }
}


extension TrackerIrregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 5// Отступ между столбцами
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 0 // Отступ между строками
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // Отступы вокруг коллекции
    }
}

extension TrackerIrregularEventViewController: CategoryViewControllerDelegate {
    func didSelectCategory(_ selectedCategory: TrackerCategory) {
        print("Selected category: \(selectedCategory.title)")
        category = selectedCategory
        optionsTableView.reloadData()
    }
}
