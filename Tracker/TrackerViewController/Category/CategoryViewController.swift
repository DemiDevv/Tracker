import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ selectedCategory: TrackerCategory)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true  // Закругление углов таблицы
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero  // Убираем внутренние отступы для разделителей
        tableView.separatorColor = .lightGray  // Цвет разделителей
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .blackDayYp
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private lazy var placeHolderView: UIView = PlaceholderView(
        model: PlaceholderModel(
            description: "Привычки и события можно\n объединить по смыслу",
            imageName: "ill_error_image"
        )
    )
    
    // MARK: - Properties
    
    weak var delegate: CategoryViewControllerDelegate?
    
    private lazy var viewModel = CategoryViewModel()
    private lazy var alertPresenter: AlertPresenterProtocol = AlertPresenter(delegate: self)
    
    private var selectedCategory: TrackerCategory?
    
    // MARK: - init
    
    init(selectedCategory: TrackerCategory?, delegate: CategoryViewControllerDelegate) {
        self.delegate = delegate
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        super.loadView()
        title = "Категория"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupLayout()
        setupButtons()
        setupTableView()
        setupBindings()
        getAllCategories()
        
        print("Create Button Frame: \(createButton.frame)")
        print("View Subviews: \(view.subviews)")
    }
}

extension CategoryViewController {
    
    private func setupLayout() {
        view.addSubview(placeHolderView)
        view.addSubview(tableView)
        view.addSubview(createButton)
        
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        placeHolderView.isHidden = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeHolderView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            placeHolderView.widthAnchor.constraint(equalToConstant: 300),
            placeHolderView.heightAnchor.constraint(equalToConstant: 300),
            placeHolderView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -232),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16)
        ])
    }
    // MARK: - setupBindings
    
    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] categories in
            guard let self = self else { return }
            self.tableView.reloadData()
            print("placeHolderView isHidden before update: \(placeHolderView.isHidden)")
            self.updatePlaceholderVisibility()
            print("Categories updated, count: \(categories.count)")
        }


        viewModel.onCategorySelected = { [weak self] category in
            guard let self = self else { return }
            self.delegate?.didSelectCategory(category)
        }
    }
    
    // MARK: - getAllCategories
    
    private func getAllCategories() {
        viewModel.loadCategories()
    }
    
    // MARK: - showPlaceHolder
    
    private func updatePlaceholderVisibility() {
        let hasCategories = viewModel.categoriesAmount > 0
        print("Categories count: \(viewModel.categoriesAmount), hasCategories: \(hasCategories)")
        
        placeHolderView.isHidden = hasCategories
        tableView.isHidden = !hasCategories
    }
    
    // MARK: - setupButtons
    
    private func setupButtons() {
        createButton.addTarget(self, action: #selector(createButtonTapAction), for: .touchUpInside)
    }
    
    // MARK: - setupTableView
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.identifier
        )
        
        tableView.separatorStyle = viewModel.categoriesAmount == 1
            ? .none
            : .singleLine
        
        tableView.tableHeaderView = UIView(frame: .zero)

    }
    
    // MARK: - createButtonTapAction
    
    @objc private func createButtonTapAction() {
        let createCategoryVC = CreateCategoryViewController(
            mode: .create,
            delegate: self,
            editingCategory: nil
        )
        let navigationController = UINavigationController(rootViewController: createCategoryVC)
        present(navigationController, animated: true)
    }
    
    // MARK: - editCategory
    
    private func editCategory(_ category: TrackerCategory) {
        let createCategoryVC = CreateCategoryViewController(
            mode: .edit,
            delegate: self,
            editingCategory: category
        )
        let navigationController = UINavigationController(rootViewController: createCategoryVC)
        present(navigationController, animated: true)
    }
    
    // MARK: - deleteCategory
    
    private func deleteCategory(_ category: TrackerCategory) {
        let alert = AlertModel(
            title: nil,
            message: "Эта категория точно не нужна?",
            buttonText: "Удалить",
            cancelButtonText: "Отменить"
        ) { [weak self] in
            guard let self else { return }
            self.viewModel.deleteCategory(category)
        }
        
        alertPresenter.showAlert(with: alert)
    }
}

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let path = UIBezierPath(roundedRect: cell.bounds,
                                            byRoundingCorners: [.bottomLeft, .bottomRight],
                                            cornerRadii: CGSize(width: 16, height: 16))
                    let mask = CAShapeLayer()
                    mask.path = path.cgPath
                    cell.layer.mask = mask
            // Убираем разделитель для последней ячейки
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            // Восстанавливаем стандартный разделитель для остальных ячеек
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            cell.layer.mask = nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let selectedIndexPath = viewModel.selectedIndexPath,
            selectedIndexPath != indexPath
        {
            let previousCell = tableView.cellForRow(at: selectedIndexPath)
            previousCell?.accessoryType = .none
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategoryBy(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75 
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = viewModel.getCategoryBy(index: indexPath.row)
        
        return UIContextMenuConfiguration(actionProvider:  { _ in
            UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    guard let self else { return }
                    self.editCategory(category)
                },
                UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.deleteCategory(category)
                }
            ])
        })
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoriesAmount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        )
        
        guard let categoryCell = cell as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.getCategoryBy(index: indexPath.row)
        let isSelected = category.title == selectedCategory?.title
        
        if isSelected {
            viewModel.saveSelected(indexPath: indexPath)
        }
        
        categoryCell.setupCell(title: category.title, isSelected: isSelected)
        
        return categoryCell
    }
}

// MARK: - CategoryViewController

extension CategoryViewController: CreateCategoryViewControllerDelegate {
    func acceptChanges() {
        getAllCategories()
        dismiss(animated: true)
    }
}

