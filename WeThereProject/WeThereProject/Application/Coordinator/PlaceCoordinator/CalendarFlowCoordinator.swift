//
//  CalendarFlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import UIKit

struct CalendarFlowCoordinator: Coordinator {
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
        let calendarViewController = container.makeCalendarViewController(with: action)
        navigationController?.pushViewController(calendarViewController, animated: false)
    }
}
