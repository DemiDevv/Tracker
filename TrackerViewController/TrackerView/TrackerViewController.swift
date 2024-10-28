import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - UI Elements
    private let addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "add_tracker_icon") ?? UIImage(),
            target: nil,
            action: nil
        )
        button.tintColor = .blackDayYp
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.tintColor = .blackDayYp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.backgroundColor = .backgroundDayYp
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private let trackerSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.layer.cornerRadius = 8
        searchBar.layer.masksToBounds = true
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    // Заглушка при отсутствии трекеров
    private let emptyPlaceholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ill_error_image"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.tintColor = .blackDayYp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция для отображения трекеров
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    var categories: [TrackerCategory] = [
        TrackerCategory(title: "Группа 1", trackers: [
            Tracker(id: UUID(), title: "Трекер 1", color: .red, emoji: "🔥", schedule: ["Monday"]),
            Tracker(id: UUID(), title: "Трекер 2", color: .green, emoji: "🌊", schedule: ["Tuesday"]),
            
        ]),
        TrackerCategory(title: "Группа 2", trackers: [
            Tracker(id: UUID(), title: "Трекер 3", color: .blue, emoji: "🌳", schedule: ["Wednesday"])
        ])
    ]
    
    // MARK: - Data
    
    var completedTrackers: [TrackerRecord] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewTrackerNotification(_:)), name: .didCreateNewTracker, object: nil)
        
        setupTrackerView()
        updateUI()
        setupCollectionView()
    }
    
    @objc private func didReceiveNewTrackerNotification(_ notification: Notification) {
        guard let newTracker = notification.object as? Tracker else { return }
        
        // Создаем новый массив категорий
        var updatedCategories: [TrackerCategory] = []
        
        var trackerAdded = false
        
        // Проходим по всем существующим категориям
        for category in categories {
            if category.title == "Нужная категория" { // Здесь может быть условие выбора нужной категории
                // Добавляем трекер в копию текущей категории
                var updatedTrackers = category.trackers
                updatedTrackers.append(newTracker)
                
                // Создаем новую категорию с обновленным списком трекеров
                let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                updatedCategories.append(updatedCategory)
                trackerAdded = true
            } else {
                // Добавляем существующую категорию без изменений
                updatedCategories.append(category)
            }
        }
        
        // Если подходящей категории не было найдено, создаем новую
        if !trackerAdded {
            let newCategory = TrackerCategory(title: "Новая категория", trackers: [newTracker])
            updatedCategories.append(newCategory)
        }
        
        // Обновляем categories новым массивом категорий
        categories = updatedCategories
        updateUI()
    }


    
    // MARK: - Setup UI
    private func setupTrackerView() {
        view.addSubview(addTrackerButton)
        view.addSubview(trackerLabel)
        view.addSubview(datePicker)
        view.addSubview(trackerSearchBar)
        
        // Добавляем заглушку и CollectionView
        view.addSubview(emptyPlaceholderImageView)
        view.addSubview(emptyPlaceholderLabel)
        view.addSubview(collectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Кнопка добавления трекера
            addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            
            // Заголовок трекеров
            trackerLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            
            // Дата пикер
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 100),
            
            // Поисковая строка
            trackerSearchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            trackerSearchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor),
            trackerSearchBar.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor),
            trackerSearchBar.heightAnchor.constraint(equalToConstant: 36),
            
            // Изображение заглушки
            emptyPlaceholderImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyPlaceholderImageView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: 220),
            emptyPlaceholderImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyPlaceholderImageView.widthAnchor.constraint(equalToConstant: 80),
            
            // Текст заглушки
            emptyPlaceholderLabel.topAnchor.constraint(equalTo: emptyPlaceholderImageView.bottomAnchor, constant: 8),
            emptyPlaceholderLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyPlaceholderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emptyPlaceholderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // Коллекция трекеров
            collectionView.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - UI Update Logic
    private func updateUI() {
        let hasTrackers = !categories.isEmpty // Используйте trackers вместо categories
        
        emptyPlaceholderImageView.isHidden = hasTrackers
        emptyPlaceholderLabel.isHidden = hasTrackers
        collectionView.isHidden = !hasTrackers
        
        if hasTrackers {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc private func addTrackerButtonTapped() {
        let trackerCreateVC = TrackerCreateViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerCreateVC, animated: true)
        } else {
            trackerCreateVC.modalPresentationStyle = .pageSheet
            present(trackerCreateVC, animated: true, completion: nil)
        }
    }
    private func setupCollectionView() {
        // Регистрируем ячейку и заголовок секции
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count // Количество категорий
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count // Количество трекеров в секции
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as! TrackerCollectionViewCell
        
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        cell.configure(with: tracker) // Конфигурируем ячейку с данными
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeaderView.identifier, for: indexPath) as! TrackerCategoryHeaderView
            let category = categories[indexPath.section]
            header.configure(with: category.title) // Устанавливаем заголовок секции
            return header
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 9 // Отступы между ячейками и краями экрана
        let availableWidth = collectionView.bounds.width - padding
        let cellWidth = availableWidth / 2 - 8 // 8 пикселей для отступа между ячейками
        
        return CGSize(width: cellWidth, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40) // Высота заголовка секции
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) // Отступы от краев экрана
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12 // Расстояние между строками ячеек
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9 // Расстояние между ячейками в строке
    }
}

extension Notification.Name {
    static let didCreateNewTracker = Notification.Name("didCreateNewTracker")
}


