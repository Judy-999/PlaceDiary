//
//  MapFlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import UIKit

struct MapFlowCoordinator: Coordinator {
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
        let mapViewController = container.makeMapViewController(with: action)
        navigationController?.pushViewController(mapViewController, animated: false)
    }
}
