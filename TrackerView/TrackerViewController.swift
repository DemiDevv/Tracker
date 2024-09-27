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
    
    private let illImageError: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ill_error_image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let illLabelError: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.tintColor = .blackDayYp
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Data
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Настройка элементов UI
        setupTrackerView()
    }
    
    // MARK: - Setup UI

    
    private func setupTrackerView() {
        view.addSubview(addTrackerButton)
        view.addSubview(trackerLabel)
        view.addSubview(datePicker)
        view.addSubview(trackerSearchBar)
        view.addSubview(illImageError)
        view.addSubview(illLabelError)
        
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
            
            // Изображение ошибки
            illImageError.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            illImageError.topAnchor.constraint(equalTo: trackerSearchBar.bottomAnchor, constant: 220),
            illImageError.heightAnchor.constraint(equalToConstant: 80),
            illImageError.widthAnchor.constraint(equalToConstant: 80),
            
            // Текст ошибки
            illLabelError.topAnchor.constraint(equalTo: illImageError.bottomAnchor, constant: 8),
            illLabelError.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            illLabelError.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            illLabelError.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
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
        // Создаем экземпляр контроллера TrackerCreateViewController
        let trackerCreateVC = TrackerCreateViewController()
        
        // Если используется UINavigationController, пушим контроллер
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerCreateVC, animated: true)
        } else {
            // Иначе презентуем его модально
            trackerCreateVC.modalPresentationStyle = .pageSheet
            present(trackerCreateVC, animated: true, completion: nil)
        }
    }

    
    // MARK: - Tracker Management Logic
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        // Находим категорию по заголовку
        if let index = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let updatedTrackers = categories[index].trackers + [tracker]
            let updatedCategory = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
            
            // Обновляем список категорий
            categories[index] = updatedCategory
        } else {
            // Если категории не существует, создаем новую категорию с трекером
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        
        print("Трекер добавлен в категорию: \(categoryTitle)")
    }
    
    func markTrackerAsCompleted(_ trackerID: UUID, on date: Date) {
        let record = TrackerRecord(trackerID: trackerID, date: date)
        completedTrackers.append(record)
        print("Трекер с ID \(trackerID) отмечен как выполненный на \(date)")
    }
    
    func unmarkTrackerAsCompleted(_ trackerID: UUID, on date: Date) {
        // Ищем запись с трекером и датой, и удаляем её
        if let index = completedTrackers.firstIndex(where: { $0.trackerID == trackerID && Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            completedTrackers.remove(at: index)
            print("Трекер с ID \(trackerID) снят с выполнения на \(date)")
        }
    }
    
    func isTrackerCompleted(_ trackerID: UUID, on date: Date) -> Bool {
        return completedTrackers.contains(where: { $0.trackerID == trackerID && Calendar.current.isDate($0.date, inSameDayAs: date) })
    }
}
