//
//  DIContainer.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/03.
//

import UIKit

final class AppDIContainer {
    // MARK: - DIContainers of scenes
    func makePlaceSceneDIContainer() -> PlaceSceneDIContainer {
        return PlaceSceneDIContainer()
    }
}

struct PlaceSceneDIContainer {
    // MARK: - Use Cases
    func makePlaceUseCase() -> PlaceUseCase {
        return PlaceUseCase(placeRepository: makePlaceRepository())
    }
    
    func makeClassificationUseCase() -> ClassificationUseCase {
        return ClassificationUseCase(placeRepository: makePlaceRepository())
    }
    
    func makeImageUseCase() -> ImageUseCase {
        return ImageUseCase(imageRepository: makeImagesRepository())
    }
    
    // MARK: - Repositories
    func makePlaceRepository() -> PlaceRepository {
        return PlaceRepository()
    }
    
    func makeImagesRepository() -> ImageRepository {
        return ImageRepository()
    }
    
    // MARK: - Place List
    func makePlaceListViewController(action: PlaceViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "PlaceList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController",
                                                                      creator: { creater in
            let mainViewController = MainViewController(with: self.makePlacesListViewModel(action: action),
                                                        imageRepository: self.makeImagesRepository(),
                                                        coder: creater)
            return mainViewController
        })
        
        return mainViewController
    }
    
    func makePlacesListViewModel(action: PlaceViewModelAction) -> MainViewModel {
        return MainViewModel(placeUseCase: makePlaceUseCase(),
                             action: action)
    }
    
    // MARK: - Place Details
    func makePlaceDetailViewController(place: Place,
                                       action: DetailViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(identifier: "InfoViewController",
                                                                       creator: { creater in
            let infoViewController = PlaceInfoTableViewController(place: place,
                                                                  viewModel: self.makePlaceDetailViewModel(action: action),
                                                                  coder: creater)
            return infoViewController
        })
        return infoViewController
    }
    
    func makePlaceDetailViewModel(action: DetailViewModelAction) -> DetailViewModel {
        return DetailViewModel(placeUseCase: makePlaceUseCase(),
                               imageUseCase: makeImageUseCase(),
                               action: action)
    }
    
    // MARK: - Add Place
    func makeAddPlaceViewController(with place: Place?) -> UIViewController {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(identifier: "AddViewController",
                                                                     creator: { creater in
            let addViewController = AddPlaceTableViewController(place: place,
                                                                 viewModel: self.makeAddPlaceViewModel(),
                                                                 coder: creater)
            return addViewController
        })
        return addViewController
    }
    
    func makeAddPlaceViewModel() -> AddViewModel {
        return AddViewModel(placeUseCase: makePlaceUseCase(),
                            imageUseCase: makeImageUseCase())
    }
    
    func makeSearchViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(identifier: "SearchViewController",
                                                                     creator: { creater in
            let searchViewController = SearchViewController()
            return searchViewController
        })
        return searchViewController
    }
    
    func makeMapViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewController = storyboard.instantiateViewController(identifier: "MapViewController",
                                                                     creator: { creater in
            let mapViewController = MapViewController()
            return mapViewController
        })
        return mapViewController
    }
    
    func makeCalendarViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let calendarViewController = storyboard.instantiateViewController(identifier: "CalendarController",
                                                                     creator: { creater in
            let calendarViewController = CalendarController()
            return calendarViewController
        })
        return calendarViewController
    }
    
    func makeSettingViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingViewController = storyboard.instantiateViewController(identifier: "SettingTableController",
                                                                     creator: { creater in
            let settingViewController = SettingTableController()
            return settingViewController
        })
        return settingViewController
    }

    // MARK: - Flow Coordinators
    func makeTabFlowCoordinator(navigationController: UINavigationController) -> TabCoordinator {
        return TabCoordinator(navigationController, container: self)
    }
    
    func makePlaceFlowCoordinator(navigationController: UINavigationController) -> PlcaeFlowCoordinator {
        return PlcaeFlowCoordinator(navigationController: navigationController,
                                    container: self)
    }
    
    func makeDetailFlowCoordinator(navigationController: UINavigationController) -> DetailFlowCoordinator {
        return DetailFlowCoordinator(navigationController: navigationController,
                                     container: self)
    }
    
    func makeSettingFlowCoordinator(navigationController: UINavigationController) -> SettingFlowCoordinator {
        return SettingFlowCoordinator(navigationController: navigationController,
                                      container: self)
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
        let action = PlaceViewModelAction(showPlaceDetails: showPlaceDetail,
                                          showPlaceAdd: showAddPlace)
        let vc = container.makePlaceListViewController(action: action)
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
//        let action = PlaceVsiewModelAction(showPlaceDetails: showPlaceDetail,
//                                          showPlaceAdd: showAddPlace)
        let vc = container.makeSettingViewController()
        navigationController?.pushViewController(vc, animated: false)
    }
}
