import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIButton = {
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
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.tintColor = .blackDayYp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .blueYp
        picker.backgroundColor = .backgroundDayYp
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        picker.maximumDate = Date()
        return picker
    }()
    
    private lazy var trackerSearchBar: UISearchTextField = {
        let textField = UISearchTextField()
        textField.backgroundColor = .backgroundDayYp
        textField.textColor = .blackDayYp
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.layer.cornerRadius = 8
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.grayYp
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes
        )
        textField.attributedPlaceholder = attributedPlaceholder
        textField.delegate = self
        
        return textField
    }()
    
    
    // Заглушка при отсутствии трекеров
    private lazy var emptyPlaceholderImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ill_error_image"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.tintColor = .blackDayYp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Коллекция для отображения трекеров
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
//    private var viewModel: TrackerViewModel?
//    
//    func initialize(viewModel: TrackerViewModel) {
//        self.viewModel = viewModel
//        bind()
//    }

    var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    private let trackerCategoryStore =  TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    lazy var trackerHabbitViewController: TrackerHabbitViewController = {
        let viewController = TrackerHabbitViewController()
        viewController.trackerHabbitDelegate = self
        return viewController
    }()
    lazy var trackerIrregularEventViewController: TrackerIrregularEventViewController = {
        let viewController = TrackerIrregularEventViewController()
        viewController.trackerHabbitDelegate = self
        return viewController
    }()
    weak var trackerHabbitDelegate: TrackerHabbitViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        showOnboarding()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTrackersUpdate),
            name: .categoryNameChanged,
            object: nil
        )
        getAllCategories()
        getCompletedTrackers()
        
        setupTrackerView()
        updateUI()
        setupCollectionView()
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
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func showOnboarding() {
        guard !UserAppSettingsStorage.shared.isOnboardingVisited else { return }
        
        UserAppSettingsStorage.shared.isOnboardingVisited = true
        let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        onboardingVC.modalPresentationStyle = .fullScreen
        present(onboardingVC, animated: true)
    }
    
    // MARK: getAllCategories
    private func getAllCategories() {
        categories = trackerCategoryStore.fetchAllCategories()
        print("categories", categories)
    }
    
    // MARK: getCompletedTrackers
    private func getCompletedTrackers() {
        completedTrackers = Set(trackerRecordStore.fetchAllRecords())
        print("completedTrackers", completedTrackers)
    }
    // MARK: - UI Update Logic
    private func updateUI() {
        collectionView.reloadData()
        datePickerValueChanged()
    }
    
    // MARK: - Actions
    @objc private func datePickerValueChanged() {
        reloadFiltredCategories()
    }
    
    @objc private func addTrackerButtonTapped() {
        let trackerCreateVC = TrackerCreateViewController()
        trackerCreateVC.trackerViewController = self
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerCreateVC, animated: true)
        } else {
            trackerCreateVC.modalPresentationStyle = .pageSheet
            present(trackerCreateVC, animated: true, completion: nil)
        }
    }
    
    private func setupCollectionView() {
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func reloadFiltredCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (trackerSearchBar.text ?? "").lowercased()
        print("Search filter: \(filterText)")
        
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                tracker.title.lowercased().contains(filterText)
                print("Checking tracker title: \(tracker.title), condition: \(textCondition)")
                
                let dateCondition = tracker.schedule.contains { weekDay in
                    print("Checking weekday: \(weekDay.rawValue), filter weekday: \(filterWeekday)")
                    return weekDay.rawValue == filterWeekday
                }
                return textCondition && dateCondition
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        collectionView.reloadData()
        reloadPlaceholder()
        
    }
    
    private func reloadPlaceholder() {
        let isEmpty = filteredCategories.isEmpty
        emptyPlaceholderImageView.isHidden = !isEmpty
        emptyPlaceholderLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        let allRecords = trackerRecordStore.fetchAllRecords()
        
        if let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }),
           tracker.type == .event {
            return allRecords.contains { $0.trackerID == id }
        }
        
        return allRecords.contains {
            $0.trackerID == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
        }
    }
}

// MARK: - UITextFieldDelegate
extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadFiltredCategories()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.identifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays: Int
        
        if tracker.type == .event {
            completedDays = completedTrackers.contains { $0.trackerID == tracker.id } ? 1 : 0 // 0 дней для новых событий
        } else {
            completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        }
        
        cell.configure(with: tracker,
                       isCompletedToday: isCompletedToday,
                       indexPath: indexPath,
                       completedDays: completedDays)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerCategoryHeaderView.identifier, for: indexPath) as? TrackerCategoryHeaderView else { return UICollectionReusableView() }
            let category = filteredCategories[indexPath.section]
            header.configure(with: category.title)
            return header
        }
        return UICollectionReusableView()
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }) else { return }
        
        let record: TrackerRecord? = {
            switch tracker.type {
            case .habbit:
                return trackerRecordStore
                    .fetchAllRecords()
                    .first { $0.trackerID == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date) }
            case .event:
                return trackerRecordStore
                    .fetchAllRecords()
                    .first { $0.trackerID == id }
            }
        }()

        if let record {
            trackerRecordStore.deleteRecord(for: record)
        } else {
            let newRecord = TrackerRecord(trackerID: id, date: tracker.type == .habbit ? datePicker.date : Date.distantPast)
            trackerRecordStore.addTrackerRecord(with: newRecord)
        }
        getCompletedTrackers()
        collectionView.reloadItems(at: [indexPath])
        collectionView.reloadData()
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        guard let tracker = filteredCategories
            .flatMap({ $0.trackers })
            .first(where: { $0.id == id }) else { return }
        
        // Привычка: Удаляем запись за текущий день
        if tracker.type == .habbit {
            if let record = trackerRecordStore
                .fetchAllRecords()
                .first(where: {
                    $0.trackerID == id && Calendar.current.isDate($0.date, inSameDayAs: datePicker.date)
                }) {
                trackerRecordStore.deleteRecord(for: record)
            }
        }
        
        else if tracker.type == .event {
            if let record = trackerRecordStore
                .fetchAllRecords()
                .first(where: { $0.trackerID == id }) {
                trackerRecordStore.deleteRecord(for: record)
            }
        }
        getCompletedTrackers()
        collectionView.reloadItems(at: [indexPath])
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    // Размеры ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16 + 9 // Отступы между ячейками и краями экрана
        let availableWidth = collectionView.bounds.width - padding
        let cellWidth = availableWidth / 2 - 8 // 8 пикселей для отступа между ячейками
        
        return CGSize(width: cellWidth, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 32, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 32
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension TrackerViewController: TrackerHabbitViewControllerDelegate {
    func didTapCreateButton(categoryTitle: String, trackerToAdd: Tracker) {
        print("🛠 Метод didTapCreateButton вызван с categoryTitle: \(categoryTitle)")
        guard let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) else {
            print("⚠️ Категория не найдена: \(categoryTitle)")
            return
        }
        dismiss(animated: true)
        do {
            try trackerStore.addNewTracker(trackerToAdd, toCategory: categories[categoryIndex])
            getAllCategories()
            getCompletedTrackers()
            reloadFiltredCategories()
            
        } catch {
            print("❌ Ошибка добавления трекера: \(error.localizedDescription)")
        }
    }
    
    func didTapCancelButton() {
        dismiss(animated: true)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        //
    }
    
    @objc func didTrackersUpdate() {
        getAllCategories()
        getCompletedTrackers()
        collectionView.reloadData()
    }
}
