import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterChangedTo(_ newFilter: FilterType)
}

final class FilterViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.layer.masksToBounds = true
        tableView.separatorColor = AppColorSettings.notActiveFontColor
        tableView.isEmptyHeaderHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    func setupTableView(source: FilterViewController) {
        tableView.delegate = source
        tableView.dataSource = source
        
        tableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.identifier
        )
        
        tableView.reloadData()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Insets.top.rawValue),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Insets.main.rawValue),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Insets.main.rawValue),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Insets.main.rawValue),
        ])
    }
    
    enum Insets: CGFloat {
        case main = 16
        case top = 24
    }
    
    // MARK: - Properties
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var selectedIndexPath: IndexPath?
    private var selectedFilter: FilterType?
    
    // MARK: - Lifecycle
    
    init(selectedFilter: FilterType?, delegate: FilterViewControllerDelegate) {
        self.delegate = delegate
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = Constants.pageTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.viewBackground
        setupTableView()
        setupLayout()
    }
}

extension FilterViewController {
    
    // MARK: - setupTableView
    
    private func setupTableView() {
        setupTableView(source: self)
    }
}

// MARK: - UITableViewDelegate

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewHeightForRowAt
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let cellCount = tableView.numberOfRows(inSection: indexPath.section)
        cell.setCustomStyle(indexPath: indexPath, cellCount: cellCount)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let selectedIndexPath = selectedIndexPath,
            selectedIndexPath != indexPath
        {
            let previousCell = tableView.cellForRow(at: selectedIndexPath)
            previousCell?.accessoryType = .none
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }

        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        selectedIndexPath = indexPath

        let selectedFilter = FilterType.allCases[indexPath.row]
        delegate?.filterChangedTo(selectedFilter)
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        )
        
        guard let categoryCell = cell as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let currentFilter = FilterType.allCases[indexPath.row]
        let isSelected = currentFilter == selectedFilter
        
        if isSelected {
            selectedIndexPath = indexPath
        }
        
        categoryCell.setupCell(title: currentFilter.title, isSelected: isSelected)
        
        return categoryCell
    }
}

// MARK: - Constants

private extension FilterViewController {
    enum Constants {
        static let pageTitle = NSLocalizedString("filters", comment: "")
        
        static let tableViewHeightForRowAt: CGFloat = 75
    }
}

