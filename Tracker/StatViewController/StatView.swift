import UIKit

final class StatisticView: UIView {
    
    static let statisticVCTitle = NSLocalizedString("statistic.screen.title", comment: "")
    
    // MARK: - Properties
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = StatisticView.statisticVCTitle
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.tintColor = Colors.fontColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statisticCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        collectionViewLayout?.sectionHeadersPinToVisibleBounds = true
        collectionViewLayout?.collectionView?.backgroundColor = Colors.viewBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private lazy var placeHolderView: UIView = PlaceholderView(
        model: PlaceholderModel(
            description: Constants.statisticPlaceHolder,
            imageName: "stat_error_image"
        )
    )
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.viewBackground
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatisticView {
    
    // MARK: - showPlaceHolder
    
    func showPlaceHolder(isVisible: Bool) {
        placeHolderView.isHidden = isVisible
    }
    
    func reloadCollection() {
        statisticCollectionView.reloadData()
    }
    
    func setupCollectionView(source: StatViewController) {
        statisticCollectionView.dataSource = source
        statisticCollectionView.delegate = source
        statisticCollectionView.register(
            StatCollectionViewCell.self,
            forCellWithReuseIdentifier: StatCollectionViewCell.identifier
        )
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        addSubview(statisticCollectionView)
        addSubview(placeHolderView)
        addSubview(trackerLabel)
        placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            trackerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 44),
            
            
            statisticCollectionView.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 53),
            statisticCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            statisticCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            statisticCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            placeHolderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeHolderView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
