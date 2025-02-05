import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func acceptChanges()
}

final class CreateCategoryViewController: UIViewController {
    // MARK: - Properties
    private lazy var categoryNameTextField: UITextField = {
        let textField = PaddedTextField()
        textField.clearButtonMode = .whileEditing
        textField.placeholder = "Введите название категории"
        textField.borderStyle = .none
        textField.backgroundColor = .backgroundDayYp
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.backgroundColor = .systemGray
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.text = "Ограничение 38 символов"
        label.textColor = .redYp
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    
    init(
        mode: CreateCategoryMode,
        delegate: CreateCategoryViewControllerDelegate,
        editingCategory: TrackerCategory?
    ) {
        self.delegate = delegate
        self.createCategoryMode = mode
        self.editingCategory = editingCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    weak var delegate: CreateCategoryViewControllerDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private var createCategoryMode: CreateCategoryMode
    private var editingCategory: TrackerCategory?
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        title = createCategoryMode.rawValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupButtons()
        setupTextField()
    }
}

extension CreateCategoryViewController {
    private func setupLayout() {
        view.addSubview(categoryNameTextField)
        view.addSubview(errorLabel)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([

            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 63),
            
            errorLabel.topAnchor.constraint(equalTo: categoryNameTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func showTrackerNameError(_ show: Bool) {
        errorLabel.isHidden = show
    }
    
    func doDoneButtonActive(_ isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled
        ? .blackDayYp
        : .systemGray
    }
    
    // MARK: - setupTextField
    
    func setupTextField() {
        categoryNameTextField.delegate = self
        categoryNameTextField.text = editingCategory?.title
    }
    
    // MARK: - setupButtons
    
    private func setupButtons() {
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)

        categoryNameTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }
    
    // MARK: - didTapDoneButton
    
    @objc private func didTapDoneButton() {
        guard let categoryName = categoryNameTextField.text else { return }
        
        switch createCategoryMode {
        case .create:
            trackerCategoryStore
                .createCategory(
                    with: TrackerCategory(
                        title: categoryName,
                        trackers: []
                    )
                )
            break
        case .edit:
            guard let editingCategory else { return }
            
            trackerCategoryStore
                .updateCategory(
                    previousName: editingCategory.title,
                    withNewName: categoryName
                )

            
            NotificationCenter.default
                .post(
                    name: .categoryNameChanged,
                    object: self,
                    userInfo: ["NewCategoryName": categoryName]
                )
            break
        }
        
        delegate?.acceptChanges()
    }
    
    // MARK: - editingChanged
    
    @objc private func editingChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        let errorIsHidden = text.count < 38
        showTrackerNameError(errorIsHidden)
        let isDoneButtonHidden = !text.isEmpty && errorIsHidden
        doDoneButtonActive(isDoneButtonHidden)
    }
}

// MARK: - UITextFieldDelegate

extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return true
    }
}

extension Notification.Name {
    static let categoryNameChanged = Notification.Name("CategoryNameChanged")
}
