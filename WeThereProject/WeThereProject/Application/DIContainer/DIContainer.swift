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
    private func makePlaceUseCase() -> PlaceUseCase {
        return PlaceUseCase(placeRepository: makePlaceRepository())
    }
    
    private func makeClassificationUseCase() -> ClassificationUseCase {
        return ClassificationUseCase(placeRepository: makePlaceRepository())
    }
    
    private func makeImageUseCase() -> ImageUseCase {
        return ImageUseCase(imageRepository: makeImagesRepository())
    }
    
    // MARK: - Repositories
    private func makePlaceRepository() -> PlaceRepository {
        return PlaceRepository()
    }
    
    private func makeImagesRepository() -> ImageRepository {
        return ImageRepository()
    }
    
    // MARK: - Place List
    func makePlaceListViewController(with action: PlaceViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "PlaceList", bundle: nil)
        let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController",
                                                                      creator: { creator in
            let mainViewController = MainViewController(with: makePlacesListViewModel(action: action),
                                                        imageRepository: makeImagesRepository(),
                                                        coder: creator)
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
                                       _ viewModel: PlaceViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Detail", bundle: nil)
        let infoViewController = storyboard.instantiateViewController(identifier: "InfoViewController",
                                                                      creator: { creator in
            let infoViewController = PlaceInfoTableViewController(place: place,
                                                                  viewModel: viewModel,
                                                                  coder: creator)
            return infoViewController
        })
        return infoViewController
    }

    // MARK: - Add Place
    func makeAddPlaceViewController(with place: Place?,
                                    _ viewModel: DefaultViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Add", bundle: nil)
        let addViewController = storyboard.instantiateViewController(identifier: "AddViewController",
                                                                     creator: { creator in
            let addViewController = AddPlaceTableViewController(place: place,
                                                                viewModel: viewModel,
                                                                coder: creator)
            return addViewController
        })
        return addViewController
    }
    
    // MARK: - Search
    func makeSearchViewModel(_ action: PlaceViewModelAction) -> SearchViewModel {
        return SearchViewModel(placeUseCase: makePlaceUseCase(),
                               action: action)
    }
    
    func makeSearchViewController(with action: PlaceViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = storyboard.instantiateViewController(identifier: "SearchViewController",
                                                                        creator: { creator in
            let searchViewController = SearchViewController(viewModel: makeSearchViewModel(action),
                                                            coder: creator)
            return searchViewController
        })
        return searchViewController
    }
    
    // MARK: - Map
    func makeMapViewModel(_ action: PlaceViewModelAction) -> MapViewModel {
        return MapViewModel(placeUseCase: makePlaceUseCase(),
                            action: action)
    }
    
    func makeMapViewController(with action: PlaceViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "Map", bundle: nil)
        let mapViewController = storyboard.instantiateViewController(identifier: "MapViewController",
                                                                     creator: { creator in
            let mapViewController = MapViewController(viewModel: makeMapViewModel(action),
                                                      coder: creator)
            return mapViewController
        })
        return mapViewController
    }
    
    // MARK: - Calendar
    func makeCalendarViewModel(_ action: PlaceViewModelAction) -> CalendarViewModel {
        return CalendarViewModel(placeUseCase: makePlaceUseCase(),
                                 action: action)
    }
    
    func makeCalendarViewController(with action: PlaceViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "Calendar", bundle: nil)
        let calendarViewController = storyboard.instantiateViewController(identifier: "CalendarController",
                                                                          creator: { creator in
            let calendarViewController = CalendarController(viewModel: makeCalendarViewModel(action),
                                                            coder: creator)
            return calendarViewController
        })
        return calendarViewController
    }
    
    // MARK: - Setting
    func makeSettingViewModel(_ action: SettingViewModelAction) -> SettingViewModel {
        return SettingViewModel(placeUseCase: makePlaceUseCase(),
                                action: action)
    }
    
    func makeStatisticsViewController(with viewModel: SettingViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let statisticsViewController = storyboard.instantiateViewController(identifier: "StatisticsTableViewController",
                                                                            creator: { creator in
            return StatisticsTableViewController(viewModel: viewModel,
                                                 coder: creator)
        })
        return statisticsViewController
    }
    
    func makeEditClassificationViewController(with viewModel: SettingViewModel,
                                              _ type: ClassificationType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let editClassificationViewController = storyboard.instantiateViewController(identifier: "EditClassificationController",
                                                                                    creator: { creator in
            return EditClassificationController(type,
                                                viewModel: viewModel,
                                                coder: creator)
        })
        return editClassificationViewController
    }
    
    func makeSettingViewController(with action: SettingViewModelAction) -> UIViewController {
        let storyboard = UIStoryboard(name: "Setting", bundle: nil)
        let settingViewController = storyboard.instantiateViewController(identifier: "SettingTableController",
                                                                         creator: { creator in
            return SettingTableController(viewModel: makeSettingViewModel(action),
                                          coder: creator)
        })
        return settingViewController
    }
    
    // MARK: - Flow Coordinators
    func makeTabFlowCoordinator(with tabBarController: UITabBarController) -> TabCoordinator {
        return TabCoordinator(tabBarController, container: self)
    }
    
    func makePlaceFlowCoordinator(with navigationController: UINavigationController) -> PlcaeFlowCoordinator {
        return PlcaeFlowCoordinator(navigationController: navigationController,
                                    container: self)
    }
    
    func makeSettingFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return SettingFlowCoordinator(navigationController: navigationController,
                                      container: self)
    }
    
    func makeSearchFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return SearchFlowCoordinator(navigationController: navigationController,
                                     container: self)
    }
    
    func makeCalendarFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return CalendarFlowCoordinator(navigationController: navigationController,
                                       container: self)
    }
    
    func makeMapFlowCoordinator(with navigationController: UINavigationController) -> Coordinator {
        return MapFlowCoordinator(navigationController: navigationController,
                                  container: self)
    }
}
