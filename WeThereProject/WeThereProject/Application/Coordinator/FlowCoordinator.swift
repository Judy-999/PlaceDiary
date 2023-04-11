//
//  FlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/03.
//

import UIKit

final class AppFlowCoordinator {
    var tabBarController: UITabBarController
    var childCoordinators = [Coordinator]()
    private let appDIContainer: AppDIContainer
    
    init(tabBarController: UITabBarController,
        appDIContainer: AppDIContainer) {
        self.tabBarController = tabBarController
        self.appDIContainer = appDIContainer
    }
    
    func start() {
        let placeDIContainer = appDIContainer.makePlaceSceneDIContainer()
        let tabCoordinator = placeDIContainer.makeTabFlowCoordinator(with: tabBarController)
        
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
}
