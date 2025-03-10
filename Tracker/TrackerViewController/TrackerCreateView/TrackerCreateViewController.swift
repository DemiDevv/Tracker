import UIKit

final class TrackerCreateViewController: UIViewController {
    weak var trackerViewController: TrackerViewController?
    
    private lazy var trackerCreateLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16)
        label.tintColor = Colors.fontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.tintColor = Colors.buttonDisabledColor
        button.setTitleColor(Colors.viewBackground, for: .normal)
        button.backgroundColor = Colors.buttonDisabledColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didHabitButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var addIrregEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(Colors.viewBackground, for: .normal)
        button.backgroundColor = Colors.buttonDisabledColor
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didIrregEventButtonTap), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.viewBackground
        
        setupTrackerView()
    }
    
    private func setupTrackerView() {
        view.addSubview(trackerCreateLabel)
        view.addSubview(addHabitButton)
        view.addSubview(addIrregEventButton)

        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Лейбл располагается сверху
            trackerCreateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerCreateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Привязка кнопки "Привычка" к центру по оси Y
            addHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            addHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Кнопка "Нерегулярное событие" под кнопкой "Привычка"
            addIrregEventButton.topAnchor.constraint(equalTo: addHabitButton.bottomAnchor, constant: 16),
            addIrregEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addIrregEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addIrregEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didHabitButtonTap() {
        guard let trackerVC = trackerViewController else {
            print("⚠️ TrackerViewController не установлен")
            return
        }

        let trackerHabbitVC = trackerVC.trackerHabbitViewController
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerHabbitVC, animated: true)
            print("✅ Перешли с помощью pushViewController")
        } else {
            trackerHabbitVC.modalPresentationStyle = .pageSheet
            present(trackerHabbitVC, animated: true) {
                print("✅ Контроллер представлен модально")
            }
        }
    }

    @objc private func didIrregEventButtonTap() {
        guard let trackerVC = trackerViewController else {
            print("⚠️ TrackerViewController не установлен")
            return
        }

        let trackerHabbitVC = trackerVC.trackerIrregularEventViewController
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerHabbitVC, animated: true)
            print("✅ Перешли с помощью pushViewController")
        } else {
            trackerHabbitVC.modalPresentationStyle = .pageSheet
            present(trackerHabbitVC, animated: true) {
                print("✅ Контроллер представлен модально")
            }
        }
    }
}
