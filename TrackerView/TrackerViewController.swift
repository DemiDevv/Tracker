import UIKit

final class TrackerViewController: UIViewController {
    private let addTrackerButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(),
            target: nil,
            action: nil
        )
        return button
    }()
    private let trackerLabel = UILabel()
    private let dateLabel = UILabel()
    private let illImageError = UIImageView()
    private let illLabelError = UILabel()
    private let trackerSearchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        createTrackerView()
    }
}

extension TrackerViewController {
    
    private func createTrackerView() {
        addTrackerButton.setImage(UIImage(named: "add_tracker_icon"), for: .normal)
        addTrackerButton.tintColor = .blackDayYp
        addTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addTrackerButton)
        addTrackerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6).isActive = true
        addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        addTrackerButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        addTrackerButton.widthAnchor.constraint(equalToConstant: 42).isActive = true
        
        trackerLabel.text = "Трекеры"
        trackerLabel.tintColor = .blackDayYp
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        trackerLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor).isActive = true
        trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        trackerLabel.heightAnchor.constraint(equalToConstant: 41).isActive = true
        trackerLabel.widthAnchor.constraint(equalToConstant: 256).isActive = true
        trackerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        dateLabel.text = "14.12.22"
        dateLabel.backgroundColor = .backgroundDayYp
        dateLabel.layer.cornerRadius = 8
        dateLabel.layer.masksToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateLabel)
        dateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 77).isActive = true
        
        trackerSearchBar.placeholder = "Поиск"
        trackerSearchBar.searchBarStyle = .minimal
        trackerSearchBar.layer.cornerRadius = 8
        trackerSearchBar.layer.masksToBounds = true
        trackerSearchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerSearchBar)
        trackerSearchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7).isActive = true
        trackerSearchBar.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor).isActive = true
        trackerSearchBar.trailingAnchor.constraint(equalTo: dateLabel.trailingAnchor).isActive = true
        trackerSearchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        illImageError.image = UIImage(named: "ill_error_image")
        illImageError.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(illImageError)
        illImageError.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        illImageError.topAnchor.constraint(equalTo: trackerSearchBar.topAnchor, constant: 220).isActive = true
        illImageError.heightAnchor.constraint(equalToConstant: 80).isActive = true
        illImageError.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        illLabelError.text = "Что будем отслеживать?"
        illLabelError.textAlignment = .center
        illLabelError.tintColor = .blackDayYp
        illLabelError.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(illLabelError)
        illLabelError.topAnchor.constraint(equalTo: illImageError.bottomAnchor, constant: 8).isActive = true
        illLabelError.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        illLabelError.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        illLabelError.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        illLabelError.font = .systemFont(ofSize: 12)
        
    }
}
