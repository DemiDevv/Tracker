import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

