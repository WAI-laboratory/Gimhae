import UIKit
import Combine

final class BaseTabBarController: UITabBarController {
    private var subscription = Set<AnyCancellable>()
    
    let mainVC = MainViewController.init()
    let cardVC = CardIntroduceViewController()
    let settingVC = SettingViewController()
    private var previousIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateTabBar()
    }
    
    
    private func initView() {
        delegate = self

        // MARK: - Main
        let mainTabSelectedImage = UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let mainTabUnSelectedImage = UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        mainVC.tabBarItem.image = mainTabUnSelectedImage
        mainVC.tabBarItem.selectedImage = mainTabSelectedImage
        
        // MARK: - Event
        
        let eventTabSelectedImage = UIImage(systemName: "tortoise", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let eventTabUnSelectedImage = UIImage(systemName: "tortoise.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        cardVC.tabBarItem.image = eventTabUnSelectedImage
        cardVC.tabBarItem.selectedImage = eventTabSelectedImage

        

        
        // MARK: - Setting
        let settingTabSelectedImage = UIImage(systemName: "text.justify", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16), scale: .large))!.imageWithoutBaseline()
        let settingTabUnSelectedImage = UIImage(systemName: "line.3.horizontal", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 16), scale: .large))!.imageWithoutBaseline()

        settingVC.tabBarItem.image = settingTabUnSelectedImage
        settingVC.tabBarItem.selectedImage = settingTabSelectedImage
        
        
        self.viewControllers = [
                UINavigationController(rootViewController: mainVC),
                UINavigationController(rootViewController: cardVC),
                UINavigationController(rootViewController: settingVC),
        ]
        for tab in tabBar.items! {
            tab.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
    
    private func updateTabBar(color: UIColor = .label) {
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .secondarySystemBackground

        tabBar.tintColor = userInterfaceStyle == .light ? .black : .white
        tabBar.unselectedItemTintColor = .secondaryLabel

        
        tabBar.layer.shadowColor = color.cgColor
        tabBar.layer.shadowOpacity = 0.08
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 5
        tabBar.layer.setNeedsDisplay()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTabBar()
    }
    
    
//    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        if motion == .motionShake && UserDefaultsData.isAddMemoOnShake {
//            mainVC.presentAddNew()
//        }
//    }
    
    func changeTab(selectedIndex: Int) {
        dismissAllViewControllers()
        popAllViewControllers()
        self.selectedIndex = selectedIndex
        self.previousIndex = self.selectedIndex
    }
    
    private func dismissAllViewControllers(animated: Bool = false) {
        if let navigationController = selectedViewController as? UINavigationController {
            navigationController.dismiss(animated: animated, completion: nil)
        }
    }

    private func popAllViewControllers() {
        for viewController in viewControllers ?? [UIViewController]() {
            if let navigationController = viewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
    
}

extension BaseTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController is MainViewController) {
            tabBar.layer.shadowColor = UIColor.clear.cgColor
        } else {
            tabBar.layer.shadowColor = UIColor.quaternaryLabel.cgColor
        }
    }


    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
    
    
}
