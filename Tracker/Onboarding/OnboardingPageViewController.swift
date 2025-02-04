import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var onboardingPageView = OnboardingPageView()
    private let pageNumber: OnboardingPage
    
    // MARK: - Init
    
    init(pageNumber: OnboardingPage) {
        self.pageNumber = pageNumber
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = onboardingPageView
        onboardingPageView.setupView(for: pageNumber)
        setupButtons()
    }
}

extension OnboardingPageViewController {
    
    // MARK: - didTapButton
    
    private func setupButtons() {
        onboardingPageView.skipTourButton.addTarget(nil, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    // MARK: - didTapButton
    
    @objc private func didTapButton() {
        dismiss(animated: true)
    }
}
