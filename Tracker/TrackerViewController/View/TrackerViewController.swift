import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(named: "add_tracker_icon") ?? UIImage(),
            target: nil,
            action: nil
        )
        button.tintColor = Colors.fontColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTrackerButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.tintColor = Colors.viewBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_RU")
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .blueYp
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        picker.maximumDate = Date()
        
        picker.updateAppearance()

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
        collectionView.backgroundColor = Colors.viewBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.filterButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .blueYp
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        return button
    }()
    
    private var filter: FilterType? {
        didSet {
            userAppSettingsStorage.selectedFilter = filter
            isFilersActive(filersActiveState.contains(filter))
            updateFilteredCategories()
        }
    }
    
    var categories: [TrackerCategory] = []
    var completedTrackers: Set<TrackerRecord> = []
    var currentDate: Date = Date()
    private let filersActiveState: [FilterType?] = [.all, .completed, .notCompleted]
    private let trackerCategoryStore =  TrackerCategoryStore()
    private var filteredCategories: [TrackerCategory] = []
    private var trackerStore = TrackerStore()
    private var trackerRecordStore = TrackerRecordStore()
    private lazy var alertPresenter: AlertPresenterProtocol = AlertPresenter(delegate: self)
    private let userAppSettingsStorage = UserAppSettingsStorage.shared
    private let analyticService: AnalyticServiceProtocol = AnalyticService()
    
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
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticService.trackOpenScreen(screen: .main)
        print("TrackerViewController did appear")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.viewBackground
        showOnboarding()
        setupTrackerView()
        setupCollectionView()
        updateUI()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didTrackersUpdate),
            name: .categoryNameChanged,
            object: nil
        )
        
        getAllCategories()
        getCompletedTrackers()
        updateFilteredCategories()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        analyticService.trackCloseScreen(screen: .main)
    }
    
    // MARK: - Setup UI
    private func setupTrackerView() {
        view.backgroundColor = Colors.viewBackground
        view.addSubview(addTrackerButton)
        view.addSubview(trackerLabel)
        view.addSubview(datePicker)
        view.addSubview(trackerSearchBar)
        
        // Добавляем заглушку и CollectionView
        view.addSubview(emptyPlaceholderImageView)
        view.addSubview(emptyPlaceholderLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func isFilersActive(_ isActive: Bool) {
        let titleColor = isActive
        ? UIColor.whiteYp
        : UIColor.blackDayYp
        filterButton.setTitleColor(titleColor, for: .normal)
    }
    
    private func showOnboarding() {
        guard !UserAppSettingsStorage.shared.isOnboardingVisited else {
            print("Onboarding already visited, skipping.")
            return
        }

        UserAppSettingsStorage.shared.isOnboardingVisited = true

        DispatchQueue.main.async {
            let onboardingVC = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            onboardingVC.modalPresentationStyle = .fullScreen
            self.present(onboardingVC, animated: true)
        }
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
    
    @objc private func didTapFilterButton() {
        analyticService.trackClick(screen: .main, item: .tapFilterButton)
        let filtersVC = FilterViewController(
            selectedFilter: filter,
            delegate: self
        )
        self.present(UINavigationController(rootViewController: filtersVC), animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        updateFilteredCategories()
    }
    
    @objc private func addTrackerButtonTapped() {
        analyticService.trackClick(screen: .main, item: .tapAddTrack)
        let trackerCreateVC = TrackerCreateViewController()
        trackerCreateVC.trackerViewController = self
        trackerCreateVC.modalPresentationStyle = .pageSheet
        present(trackerCreateVC, animated: true, completion: nil)
    }
    
    private func setupCollectionView() {
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collectionView.register(TrackerCategoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerCategoryHeaderView.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func updateFilteredCategories() {
        switch filter {
        case .all, .none, .today:
            reloadFiltredCategories { id in
                true
            }
        case .completed:
            reloadFiltredCategories { id in
                completedTrackers
                    .contains {
                        $0.trackerID == id && $0.date == currentDate
                    }
            }
        case .notCompleted:
            reloadFiltredCategories { id in
                !completedTrackers
                    .contains {
                        $0.trackerID == id && $0.date == currentDate
                    }
            }
        }
        
        collectionView.reloadData()
    }
    
    private func reloadFiltredCategories(additionalFilter: ((UUID) -> Bool)) {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (trackerSearchBar.text ?? "").lowercased()
        print("Search filter: \(filterText)")

        // Обновляем filteredCategories на основе актуальных данных из categories
        filteredCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty ||
                    tracker.title.lowercased().contains(filterText)
                print("Checking tracker title: \(tracker.title), condition: \(textCondition)")

                let dateCondition = tracker.schedule.contains { weekDay in
                    print("Checking weekday: \(weekDay.rawValue), filter weekday: \(filterWeekday)")
                    return weekDay.rawValue == filterWeekday
                }

                let additionalCondition = additionalFilter(tracker.id)

                return textCondition && dateCondition && additionalCondition
            }

            if trackers.isEmpty {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }

        filteredCategories = sortCategories(filteredCategories)
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
    
    private func sortCategories(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        var cleanCategories: [TrackerCategory] = []
        var pinnedTrackerList: [Tracker] = []
        
        categories.forEach { category in
            var trackers: [Tracker] = []
            var pinnedTrackers: [Tracker] = []
            
            category.trackers.forEach { trackerData in
                let isPinned = trackerData.isPinned
                isPinned
                    ? pinnedTrackers.append(trackerData)
                    : trackers.append(trackerData)
            }
            
            if !pinnedTrackers.isEmpty {
                pinnedTrackerList.append(contentsOf: pinnedTrackers)
            }
            
            if !trackers.isEmpty {
                cleanCategories
                    .append(
                        TrackerCategory(
                            title: category.title,
                            trackers: trackers.sorted(by: {$0.title > $1.title})
                        )
                    )
            }
        }
        
        if !pinnedTrackerList.isEmpty {
            let pinnedCategory = TrackerCategory(
                title: "Закрепленные",
                trackers: pinnedTrackerList.sorted(by: {$0.title > $1.title})
            )
            cleanCategories.insert(pinnedCategory, at: 0)
        }
        
        return cleanCategories
    }
}

// MARK: - UITextFieldDelegate
extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateFilteredCategories()
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.row]
        let pinUnpinMessage = tracker.isPinned ? Constants.unpinMessage : Constants.pinMessage
        let category = filteredCategories[indexPath.section]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions in
            return UIMenu(
                children: [
                    UIAction(title: pinUnpinMessage) { [weak self] _ in
                        guard let self else { return }
                        
                        let trackerPinned = Tracker(
                            id: tracker.id,
                            title: tracker.title,
                            color: tracker.color,
                            emoji: tracker.emoji,
                            schedule: tracker.schedule,
                            type: tracker.type,
                            isPinned: !tracker.isPinned
                        )
                        
                        self.trackerStore.updateTrackerPin(trackerPinned)
                        self.getAllCategories()
                        self.updateFilteredCategories()
                        self.collectionView.reloadData()
                    },
                    UIAction(title: Constants.editMessage) { [weak self] _ in
                        guard let self else { return }
                        let daysCount = self.completedTrackers.filter { $0.trackerID == tracker.id }.count
                        let trackerType = tracker.type
                        
                        var realCategory: TrackerCategory? = nil

                        for category in categories {
                            let filteredTrackers = category.trackers.filter { tracker.id == $0.id
                            }
                            
                            if !filteredTrackers.isEmpty {
                                realCategory = category
                            }
                        }
                        
                        let newTrackerVC = TrackerHabbitViewController()
                        self.present(UINavigationController(rootViewController: newTrackerVC), animated: true)
                    },
                    UIAction(title: Constants.deleteMessage, attributes: .destructive) { [weak self] _ in
                        guard let self else { return }
                        self.analyticService.trackClick(screen: .main, item: .deleteFromContextMenu)
                        self.deleteTracker(tracker)
                    }
                ]
            )
        }
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        let alert = AlertModel(
            title: nil,
            message: Constants.alertMessage,
            buttonText: Constants.deleteMessage,
            cancelButtonText: Constants.cancelMessage
        ) { [weak self] in
            guard let self else { return }
            self.trackerStore.deleteTracker(tracker)
            self.getAllCategories()
            self.updateFilteredCategories()
            self.collectionView.reloadData()
        }
        alertPresenter.showAlert(with: alert)
    }
    
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
        getAllCategories()
        guard let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) else {
            print("⚠️ Категория не найдена: \(categoryTitle)")
            return
        }
        dismiss(animated: true)
        do {
            try trackerStore.addNewTracker(trackerToAdd, toCategory: categories[categoryIndex])
            getAllCategories()
            getCompletedTrackers()
            updateFilteredCategories()
            
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
        updateFilteredCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: FilterViewControllerDelegate {
    func filterChangedTo(_ newFilter: FilterType) {
        guard newFilter == .today else {
            filter = newFilter
            return
        }
        
        currentDate = Calendar.current.startOfDay(for: Date())
        datePicker.date = currentDate
        filter = nil
    }
}

private extension TrackerViewController {
    enum Constants {
        static let searchPlaceholder = NSLocalizedString("searchPlaceholder", comment: "")
        static let filterButtonTitle = NSLocalizedString("filters", comment: "")
        static let dataPickerLocal = NSLocalizedString("datePicker", comment: "")
        static let pinnedCategory = NSLocalizedString("tracker.screen.pinnedCategory", comment: "")
        static let pinMessage = NSLocalizedString("pin", comment: "")
        static let unpinMessage = NSLocalizedString("unpin", comment: "")
        static let editMessage = NSLocalizedString("edit", comment: "")
        static let deleteMessage = NSLocalizedString("delete", comment: "")
        static let cancelMessage = NSLocalizedString("cancel", comment: "")
        static let alertMessage = NSLocalizedString("tracker.screen.alertMessage", comment: "")
    }
}
