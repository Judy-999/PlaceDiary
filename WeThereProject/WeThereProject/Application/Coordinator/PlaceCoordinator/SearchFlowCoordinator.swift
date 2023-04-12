//
//  SearchFlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import UIKit

struct SearchFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    
    init(navigationController: UINavigationController,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let action = PlaceViewModelAction(showPlaceDetails: showPlaceDetail,
                                          showPlaceAdd: showAddPlace)
        let searchViewController = container.makeSearchViewController(with: action)
        navigationController?.pushViewController(searchViewController, animated: false)
    }
}
