import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private lazy var pages: [UIViewController] = {
        
        let blue = UIViewController()
        blue.view.addSubview(backgroundImageView(named: "backgroundBlue"))
        
        let red = UIViewController()
        red.view.addSubview(backgroundImageView(named: "backgroundRed"))
        
        return [blue, red]
    }()
    

    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .blackDayYp
        pageControl.pageIndicatorTintColor = .grayYp

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = pageTexts[0]
        label.textColor = .blackDayYp
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .blackDayYp
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        return button
    }()
    
    private let pageTexts = [
        "Отслеживайте только то, что хотите",
        "Даже если это не литры воды и йога"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        setupViews()
        
    }
    
    private func setupViews() {
        view.addSubview(pageControl)
        view.addSubview(createButton)
        view.addSubview(textLabel)
        

        NSLayoutConstraint.activate([
            

            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -130),
//            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageControl.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        ])
    }
    
    private func backgroundImageView(named imageName: String) -> UIImageView {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    @objc private func didTapCreateButton() {
        let trackerCreateVC = TabBarController()
        trackerCreateVC.onboardingViewController = self
        if let navigationController = self.navigationController {
            navigationController.pushViewController(trackerCreateVC, animated: true)
        } else {
            trackerCreateVC.modalPresentationStyle = .fullScreen
            present(trackerCreateVC, animated: true, completion: nil)
        }
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return pages.last
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else {
            return pages.first
        }

        return pages[nextIndex]
    }

    // MARK: - UIPageViewControllerDelegate

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
            textLabel.text = pageTexts[currentIndex]
        }
    }
}
