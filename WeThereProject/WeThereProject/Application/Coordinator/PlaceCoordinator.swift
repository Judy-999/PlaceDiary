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
    func showPlaceDetail(with place: Place, _ viewModel: PlaceViewModel)
    func showAddPlace(with place: Place?, _ viewModel: DefaultViewModelType)
}

extension Coordinator {
    func showPlaceDetail(with place: Place, _ viewModel: PlaceViewModel) {
        let vc = container.makePlaceDetailViewController(place, viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAddPlace(with place: Place?, _ viewModel: DefaultViewModelType) {
        let vc = container.makeAddPlaceViewController(with: place, viewModel)
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
        let vc = container.makePlaceListViewController(with: action)
        navigationController?.pushViewController(vc, animated: false)
    }
}

struct SettingFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    
    init(navigationController: UINavigationController,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let action = SettingViewModelAction(showEditClassification: showEditClassification,
                                            showStatistics: showStatistics)
        let vc = container.makeSettingViewController(with: action)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    private func showEditClassification(type: ClassificationType,
                                        _ viewmodel: SettingViewModel) {
        let vc = container.makeEditClassificationViewController(with: viewmodel, type)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showStatistics(_ viewmodel: SettingViewModel) {
        let vc = container.makeStatisticsViewController(with: viewmodel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

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
        let vc = container.makeSearchViewController(with: action)
        navigationController?.pushViewController(vc, animated: false)
    }
}

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
        let vc = container.makeMapViewController(with: action)
        navigationController?.pushViewController(vc, animated: false)
    }
}

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
        let vc = container.makeCalendarViewController(with: action)
        navigationController?.pushViewController(vc, animated: false)
    }
}
