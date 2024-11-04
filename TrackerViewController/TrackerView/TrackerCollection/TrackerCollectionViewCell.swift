import UIKit

class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements

    // Эмодзи трекера
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    // Название трекера
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Цвет фона ячейки
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Количество дней
    let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Кнопка с плюсом
    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "plus_button"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    var trackerID: UUID? // Идентификатор трекера
    var isCompleted: Bool = false {
        didSet {
            // Изменяем изображение кнопки при изменении состояния
            let imageName = isCompleted ? "completed_button" : "plus_button"
            addButton.setImage(UIImage(named: imageName), for: .normal)
        }
    }

    
    static let identifier = "TrackerCell"
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Добавляем подэлементы
        contentView.addSubview(colorView)
        colorView.addSubview(emojiLabel)
        colorView.addSubview(titleLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(addButton)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Фон ячейки
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            // Эмодзи трекера
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 10),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 10),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Название трекера
            titleLabel.centerXAnchor.constraint(equalTo: colorView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            
            // Количество дней
            daysLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 16),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            // Кнопка с плюсом
            addButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34), // Устанавливаем ширину 34
            addButton.heightAnchor.constraint(equalToConstant: 34) // Устанавливаем высоту 34

        ])
    }
    
    // MARK: - Configuration
    @objc private func addButtonTapped() {
        guard let trackerID = trackerID else { return }
        // Отправляем уведомление для изменения статуса выполнения трекера
        NotificationCenter.default.post(name: .didToggleTrackerCompletion, object: trackerID)
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, daysCompleted: Int) {
        print("Color for button:", tracker.color)  // Проверка цвета
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        colorView.backgroundColor = tracker.color
        addButton.tintColor = tracker.color
        daysLabel.text = "\(daysCompleted) дней"
        self.trackerID = tracker.id
        self.isCompleted = isCompleted
    }

}

extension Notification.Name {
    static let didToggleTrackerCompletion = Notification.Name("didToggleTrackerCompletion")
}
