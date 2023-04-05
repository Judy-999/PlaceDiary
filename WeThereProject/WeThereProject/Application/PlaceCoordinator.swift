//
//  PlaceCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/04.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var container: PlaceSceneDIContainer { get }
    func start()
    func showPlaceDetail(place: Place)
    func showAddPlace(with place: Place?)
}

extension Coordinator {
    func showPlaceDetail(place: Place) {
        let action = DetailViewModelAction(showPlaceAdd: showAddPlace)
        let vc = container.makePlaceDetailViewController(place: place, action: action)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAddPlace(with place: Place?) {
        let vc = container.makeAddPlaceViewController(with: place)
        navigationController?.pushViewController(vc, animated: true)
    }
}

struct PlcaeFlowCoordinator: Coordinator {
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
        let vc = container.makePlaceListViewController(action: action)
        navigationController?.pushViewController(vc, animated: false)
    }
}
