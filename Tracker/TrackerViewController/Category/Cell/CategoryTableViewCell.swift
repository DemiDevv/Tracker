import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "CategoryTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private let labelsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .backgroundDayYp
        selectionStyle = .none
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryTableViewCell {
    
    // MARK: - Layout
    
    private func setupLayout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.addArrangedSubview(nameLabel)
        
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelsStack)

        NSLayoutConstraint.activate([
            labelsStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            labelsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -56),
            labelsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }
    
    // MARK: - prepareForReuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        accessoryType = .none
    }
    
    // MARK: - setupCell
    
    func setupCell(title: String, isSelected: Bool) {
        nameLabel.text = title

        if isSelected {
            accessoryType = .checkmark
        }
    }
}
