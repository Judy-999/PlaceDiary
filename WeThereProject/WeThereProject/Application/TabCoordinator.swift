//
//  TabCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import UIKit

class TabCoordinator: NSObject, Coordinator {
    let container: PlaceSceneDIContainer
    var childCoordinators: [Coordinator] = []
    weak var navigationController: UINavigationController?
    var tabBarController: UITabBarController
    
    required init(_ navigationController: UINavigationController,
                  container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.tabBarController = .init()
        self.container = container
    }

    func start() {
        let pages: [TabBarPage] = [.list, .search, .calendar, .map, .setting]
            .sorted(by: { $0.number < $1.number })
        
        let controllers: [UINavigationController] = pages.map({ getTabController($0)})
        
        prepareTabBarController(withTabControllers: controllers)
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.list.number
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.tintColor = TabBarPage.selectedColor
        navigationController?.viewControllers = [tabBarController]
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navController = UINavigationController()
        navController.setNavigationBarHidden(false, animated: false)

        navController.tabBarItem = UITabBarItem.init(title: page.title,
                                                     image: page.icon,
                                                     tag: page.number)
        
        switch page {
        case .list:
            let main = container.makePlaceFlowCoordinator(navigationController: navController)
            main.start()
        case .search:
            let main = UIViewController()
            navController.pushViewController(main, animated: true)
        case .calendar:
            let main = container.makePlaceFlowCoordinator(navigationController: navController)
            main.start()
        case .map:
            let main = container.makePlaceFlowCoordinator(navigationController: navController)
            main.start()
        case .setting:
            let main = container.makePlaceFlowCoordinator(navigationController: navController)
            main.start()
        }

        return navController
    }
}
