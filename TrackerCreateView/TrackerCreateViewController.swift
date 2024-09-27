import UIKit

final class TrackerCreateViewController: UIViewController {
    private let trackerCreateLabel: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16)
        label.tintColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addHabitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Привычка", for: .normal)
        button.tintColor = .black
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didHabitButtonTap), for: .touchUpInside)
        return button
    }()
    
    private let addIrregEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нерегулярное событие", for: .normal)
        button.tintColor = .black
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didIrregEventButtonTap), for: .touchUpInside)
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
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
    
    @objc func didHabitButtonTap() {
        // Действие при нажатии на кнопку "Привычка"
    }
    
    @objc func didIrregEventButtonTap() {
        // Действие при нажатии на кнопку "Нерегулярное событие"
    }
}
