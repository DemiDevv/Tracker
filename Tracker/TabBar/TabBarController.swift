import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = Colors.viewBackground
            UITabBar.appearance().standardAppearance = tabBarAppearance
            

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }

        // Создание первого ViewController
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: Constants.trackerVCVCTitle,
            image: UIImage(named: "home_icon"),
            selectedImage: UIImage(named: "home_icon")
        )
        
        // Создание второго ViewController
        let statViewController = StatViewController()
        statViewController.tabBarItem = UITabBarItem(
            title: Constants.statisticVCTitle,
            image: UIImage(named: "stat_icon"),
            selectedImage: UIImage(named: "stat_icon")
        )
        
        // Добавление ViewControllers в TabBarController
        self.viewControllers = [trackerViewController, statViewController]
    }
}

private extension TabBarController {
    enum Constants {
        static let statisticVCTitle = NSLocalizedString("statistic.screen.title", comment: "")
        static let trackerVCVCTitle = NSLocalizedString("trackers.screen.title", comment: "")
    }
}
