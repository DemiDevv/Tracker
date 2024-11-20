import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = UIColor.whiteYp
            UITabBar.appearance().standardAppearance = tabBarAppearance

            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }

        // Создание первого ViewController
        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "home_icon"),
            selectedImage: UIImage(named: "home_icon")
        )
        
        // Создание второго ViewController
        let statViewController = StatViewController()
        statViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "stat_icon"),
            selectedImage: UIImage(named: "stat_icon")
        )
        
        // Добавление ViewControllers в TabBarController
        self.viewControllers = [trackerViewController, statViewController]
    }
}

