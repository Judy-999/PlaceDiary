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
    var mainViewModel: MainViewModel?
    
    required init(_ tabBarController: UITabBarController,
                  container: PlaceSceneDIContainer) {
        self.tabBarController = tabBarController
        self.container = container
    }

    func start() {
        let action = PlaceViewModelAction(showPlaceDetails: showPlaceDetail,
                                                        showPlaceAdd: showAddPlace)
        mainViewModel = container.makePlacesListViewModel(action: action)
        
        let controllers = TabBarPage.allCases.map { getTabController($0) }
        prepareTabBarController(withTabControllers: controllers)
    }
    
    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.setViewControllers(tabControllers, animated: true)
        tabBarController.selectedIndex = TabBarPage.list.number
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.tintColor = TabBarPage.selectedColor
    }
      
    private func getTabController(_ page: TabBarPage) -> UINavigationController {
        guard let viewModel = mainViewModel else { return UINavigationController() }
        let navigationController = UINavigationController()
        navigationController.setNavigationBarHidden(false, animated: false)
        navigationController.tabBarItem = UITabBarItem.init(title: page.title,
                                                     image: page.icon,
                                                     tag: page.number)
        
        switch page {
        case .list:
            let main = container.makePlaceFlowCoordinator(with: navigationController, viewModel)
            main.start()
        case .search:
            let search = container.makeSearchFlowCoordinator(with: navigationController, viewModel)
            search.start()
        case .calendar:
            let calendar = container.makeCalendarFlowCoordinator(with: navigationController, viewModel)
            calendar.start()
        case .map:
            let map = container.makeMapFlowCoordinator(with: navigationController, viewModel)
            map.start()
        case .setting:
            let setting = container.makeSettingFlowCoordinator(with: navigationController )
            setting.start()
        }

        return navigationController
    }
}
