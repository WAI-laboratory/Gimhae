import UIKit
import Combine

final class BaseTabBarController: UITabBarController {
    private var subscription = Set<AnyCancellable>()
    
    let homeVC = HomeViewController()
    let exploreVC = ExploreViewController()
    let mainVC = MainViewController()
    let myTripVC = MyTripViewController()
    
    private var previousIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateTabBar()
    }
    
    private func initView() {
        delegate = self

        // MARK: - Home (홈)
        let homeSelected = UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let homeUnselected = UIImage(systemName: "house", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        homeVC.tabBarItem = UITabBarItem(title: "tab.home".localized, image: homeUnselected, selectedImage: homeSelected)
        
        // MARK: - Explore (탐색)
        let exploreSelected = UIImage(systemName: "safari.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let exploreUnselected = UIImage(systemName: "safari", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        exploreVC.tabBarItem = UITabBarItem(title: "tab.explore".localized, image: exploreUnselected, selectedImage: exploreSelected)
        
        // MARK: - Map (지도)
        let mapSelected = UIImage(systemName: "map.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let mapUnselected = UIImage(systemName: "map", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        mainVC.tabBarItem = UITabBarItem(title: "tab.map".localized, image: mapUnselected, selectedImage: mapSelected)
        
        // MARK: - My Trip (내 여행)
        let tripSelected = UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))!.imageWithoutBaseline()
        let tripUnselected = UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))!.imageWithoutBaseline()
        myTripVC.tabBarItem = UITabBarItem(title: "tab.myTrip".localized, image: tripUnselected, selectedImage: tripSelected)
        
        self.viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: exploreVC),
            UINavigationController(rootViewController: mainVC),
            UINavigationController(rootViewController: myTripVC),
        ]
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
