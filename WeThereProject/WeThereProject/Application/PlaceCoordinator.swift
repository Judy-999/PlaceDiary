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
    func showPlaceDetail(with place: Place, _ viewModel: MainViewModel)
    func showAddPlace(with place: Place?, _ viewModel: MainViewModel)
}

extension Coordinator {
    func showPlaceDetail(with place: Place, _ viewModel: MainViewModel) {
        let vc = container.makePlaceDetailViewController(place, viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAddPlace(with place: Place?, _ viewModel: MainViewModel) {
        let vc = container.makeAddPlaceViewController(with: place, viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

struct PlcaeFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    let mainViewModel: MainViewModel
    
    init(navigationController: UINavigationController,
         viewModel: MainViewModel,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.mainViewModel = viewModel
        self.container = container
    }
    
    func start() {
        let vc = container.makePlaceListViewController(with: mainViewModel)
        navigationController?.pushViewController(vc, animated: false)
    }
}

struct DetailFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    
    init(navigationController: UINavigationController,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
//        let action = PlaceViewModelAction(showPlaceDetails: showPlaceDetail,
//                                          showPlaceAdd: showAddPlace)
//        let vc = container.makePlaceListViewController(action: action)
//        navigationController?.pushViewController(vc, animated: false)
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
        let vc = container.makeSettingViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
}

struct SearchFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    let mainViewModel: MainViewModel
    
    init(navigationController: UINavigationController,
         viewModel: MainViewModel,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.mainViewModel = viewModel
        self.container = container
    }
    
    func start() {
        let vc = container.makeSearchViewController(with: mainViewModel)
        navigationController?.pushViewController(vc, animated: false)
    }
}

struct MapFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    let mainViewModel: MainViewModel
    
    init(navigationController: UINavigationController,
         viewModel: MainViewModel,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.mainViewModel = viewModel
        self.container = container
    }
    
    func start() {
        let vc = container.makeMapViewController(with: mainViewModel)
        navigationController?.pushViewController(vc, animated: false)
    }
}

struct CalendarFlowCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    let container: PlaceSceneDIContainer
    let mainViewModel: MainViewModel
    
    init(navigationController: UINavigationController,
         viewModel: MainViewModel,
         container: PlaceSceneDIContainer) {
        self.navigationController = navigationController
        self.mainViewModel = viewModel
        self.container = container
    }
    
    func start() {
        let vc = container.makeCalendarViewController(with: mainViewModel)
        navigationController?.pushViewController(vc, animated: false)
    }
}
