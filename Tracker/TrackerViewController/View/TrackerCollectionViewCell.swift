import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleteTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements

    // Эмодзи трекера
    private lazy var emojiLabel: UILabel = {
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
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Цвет фона ячейки
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Количество дней
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = Colors.fontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Кнопка с плюсом
    private lazy var addButton: UIButton = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize)
        let button = UIButton()
        button.backgroundColor = Colors.fontColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        button.tintColor = Colors.viewBackground
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize) ?? UIImage()
        return image
    }()
    
    private lazy var pinnedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.image = UIImage(named: "pin_fill")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var completedImage = UIImage(named: "completed_image")
    
    weak var delegate: TrackerCellDelegate?
    var trackerID: UUID?
    private var indexPath: IndexPath?
    private var isCompletedToday: Bool = false
    private let analyticService: AnalyticServiceProtocol = AnalyticService()
    
    static let identifier = "TrackerCell"
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Добавляем подэлементы
        contentView.addSubview(colorView)
        colorView.addSubview(emojiLabel)
        colorView.addSubview(titleLabel)
        colorView.addSubview(pinnedImageView)
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
            
            pinnedImageView.heightAnchor.constraint(equalToConstant: 24),
            pinnedImageView.widthAnchor.constraint(equalToConstant: 24),
            pinnedImageView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -4),
            pinnedImageView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            
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
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10) || remainder100 >= 20 {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    // MARK: - Configuration
    @objc private func addButtonTapped() {
        analyticService.trackClick(screen: .main, item: .tapTracker)
        guard let trackerID = trackerID, let indexPath = indexPath else {
            assertionFailure("no trackerID")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerID, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerID, at: indexPath)
        }
    }
    
    func configure(
        with tracker: Tracker,
        isCompletedToday: Bool,
        indexPath: IndexPath,
        completedDays: Int
    ) {
        self.trackerID = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        colorView.backgroundColor = tracker.color
        addButton.backgroundColor = tracker.color
        pinnedImageView.isHidden = !tracker.isPinned
        
        // Обновление фона кнопки в зависимости от статуса выполнения
        if isCompletedToday {
            addButton.backgroundColor = tracker.color.withAlphaComponent(0.3)
        } else {
            addButton.backgroundColor = tracker.color
        }
        
        daysLabel.text = String.localizedStringWithFormat(Constants.numberOfDays, completedDays)
        
        let image = isCompletedToday ? completedImage : plusImage
        addButton.setImage(image, for: .normal)
    }
}

private extension TrackerCollectionViewCell {
    enum Constants {
        static let numberOfDays = NSLocalizedString("numberOfDays", comment: "Number of completed habbits/events in days")
    }
}
