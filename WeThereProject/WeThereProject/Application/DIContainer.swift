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
    func makePlaceListViewController(with viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "PlaceList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController",
                                                                      creator: { creater in
            let mainViewController = MainViewController(with: viewModel,
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
    func makePlaceDetailViewController(_ place: Place,
                                       _ viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(identifier: "InfoViewController",
                                                                      creator: { creater in
            let infoViewController = PlaceInfoTableViewController(place: place,
                                                                  viewModel: viewModel,
                                                                  coder: creater)
            return infoViewController
        })
        return infoViewController
    }

    // MARK: - Add Place
    func makeAddPlaceViewController(with place: Place?, _ viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(identifier: "AddViewController",
                                                                     creator: { creater in
            let addViewController = AddPlaceTableViewController(place: place,
                                                                viewModel: viewModel,
                                                                coder: creater)
            return addViewController
        })
        return addViewController
    }
    
    func makeSearchViewController(with viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(identifier: "SearchViewController",
                                                                        creator: { creater in
            let searchViewController = SearchViewController(viewModel: viewModel,
                                                            coder: creater)
            return searchViewController
        })
        return searchViewController
    }
    
    func makeMapViewController(with viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewController = storyboard.instantiateViewController(identifier: "MapViewController",
                                                                     creator: { creater in
            let mapViewController = MapViewController(viewModel: viewModel,
                                                      coder: creater)
            return mapViewController
        })
        return mapViewController
    }
    
    func makeCalendarViewController(with viewModel: MainViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let calendarViewController = storyboard.instantiateViewController(identifier: "CalendarController",
                                                                          creator: { creater in
            let calendarViewController = CalendarController(viewModel: viewModel,
                                                            coder: creater)
            return calendarViewController
        })
        return calendarViewController
    }
    
    func makeSettingViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingViewController = storyboard.instantiateViewController(identifier: "SettingTableController",
                                                                         creator: { creater in
            let settingViewController = SettingTableController(coder: creater)
            return settingViewController
        })
        return settingViewController
    }
    
    // MARK: - Flow Coordinators
    func makeTabFlowCoordinator(with tabBarController: UITabBarController) -> TabCoordinator {
        return TabCoordinator(tabBarController, container: self)
    }
    
    func makePlaceFlowCoordinator(with navigationController: UINavigationController,
                                  _ viewModel: MainViewModel) -> PlcaeFlowCoordinator {
        return PlcaeFlowCoordinator(navigationController: navigationController,
                                    viewModel: viewModel,
                                    container: self)
    }
    
    func makeDetailFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return DetailFlowCoordinator(navigationController: navigationController,
                                     container: self)
    }
    
    func makeSettingFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return SettingFlowCoordinator(navigationController: navigationController,
                                      container: self)
    }
    
    func makeSearchFlowCoordinator(with navigationController: UINavigationController,
                                   _ viewModel: MainViewModel) -> Coordinator {
        return SearchFlowCoordinator(navigationController: navigationController,
                                     viewModel: viewModel,
                                     container: self)
    }
    
    func makeCalendarFlowCoordinator(with navigationController: UINavigationController,
                                     _ viewModel: MainViewModel) -> Coordinator {
        return CalendarFlowCoordinator(navigationController: navigationController,
                                       viewModel: viewModel,
                                       container: self)
    }
    
    func makeMapFlowCoordinator(with navigationController: UINavigationController,
                                _ viewModel: MainViewModel) -> Coordinator {
        return MapFlowCoordinator(navigationController: navigationController,
                                  viewModel: viewModel,
                                  container: self)
    }
}
