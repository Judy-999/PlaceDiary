//
//  FlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/03.
//

import UIKit

final class AppFlowCoordinator {
    var navigationController: UINavigationController
    var childCoordinators = [Coordinator]()
    private let appDIContainer: AppDIContainer
    
    init(navigationController: UINavigationController,
        appDIContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
//        let moviesSceneDIContainer = appDIContainer.makePlaceSceneDIContainer()
//        let flow = moviesSceneDIContainer.makePlaceFlowCoordinator(navigationController: navigationController)
//        flow.start()
    }
    
    func showMainFlow() {
        let moviesSceneDIContainer = appDIContainer.makePlaceSceneDIContainer()
        let tabCoordinator = moviesSceneDIContainer.makeTabFlowCoordinator(navigationController: navigationController)
        
        tabCoordinator.start()
        childCoordinators.append(tabCoordinator)
    }
}
