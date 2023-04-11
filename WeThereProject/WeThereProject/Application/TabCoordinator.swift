//
//  TabCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import UIKit

class TabCoordinator: NSObject, Coordinator {
    let container: PlaceSceneDIContainer
    weak var navigationController: UINavigationController?
    var tabBarController: UITabBarController
    
    required init(_ tabBarController: UITabBarController,
                  container: PlaceSceneDIContainer) {
        self.tabBarController = tabBarController
        self.container = container
    }

    func start() {
        let controllers = TabBarPage.allCases.map { getTabController($0) }
        prepareTabBarController(with: controllers)
    }
    
    private func prepareTabBarController(with tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.list.number
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = .systemBackground
        tabBarController.tabBar.tintColor = TabBarPage.selectedColor
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.tabBarItem = UITabBarItem.init(title: page.title,
                                                     image: page.icon,
                                                     tag: page.number)
        
        switch page {
        case .list:
            let main = container.makePlaceFlowCoordinator(with: navigationController)
            main.start()
        case .search:
            let search = container.makeSearchFlowCoordinator(with: navigationController)
            search.start()
        case .calendar:
            let calendar = container.makeCalendarFlowCoordinator(with: navigationController)
            calendar.start()
        case .map:
            let map = container.makeMapFlowCoordinator(with: navigationController)
            map.start()
        case .setting:
            let setting = container.makeSettingFlowCoordinator(with: navigationController)
            setting.start()
        }

        return navigationController
    }
}
