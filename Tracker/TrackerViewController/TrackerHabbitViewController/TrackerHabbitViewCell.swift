import UIKit

final class TrackerHabbitViewCell: UICollectionViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = Colors.viewBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 16
        return label
    }()
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.clear.cgColor // Изначально рамка прозрачная
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var innerColorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .red // Цвет заливки
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorView)
        colorView.addSubview(innerColorView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 52),
            titleLabel.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            innerColorView.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 6),
            innerColorView.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -6),
            innerColorView.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 6),
            innerColorView.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -6)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    private func updateAppearance() {
        if isSelected {
            if titleLabel.text != nil {
                // Это ячейка с эмодзи
                titleLabel.backgroundColor = Colors.hightlightCell
            } else {
                // Это ячейка с цветом
                colorView.layer.borderColor = innerColorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            }
        } else {
            if titleLabel.text != nil {
                // Это ячейка с эмодзи
                titleLabel.backgroundColor = Colors.viewBackground
            } else {
                // Это ячейка с цветом
                colorView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance() // Обновляем цвета при изменении темы
    }
}
