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

protocol MoviesSearchFlowCoordinatorDependencies  {
//    func makeMoviesListViewController(
//        actions: MoviesListViewModelActions
//    ) -> MoviesListViewController
//    func makeMoviesDetailsViewController(movie: Movie) -> UIViewController
//    func makeMoviesQueriesSuggestionsListViewController(
//        didSelect: @escaping MoviesQueryListViewModelDidSelectAction
//    ) -> UIViewController
}

struct PlaceSceneDIContainer: MoviesSearchFlowCoordinatorDependencies {
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

    // MARK: - Flow Coordinators
    func makePlaceFlowCoordinator(navigationController: UINavigationController) -> PlcaeFlowCoordinator {
        return PlcaeFlowCoordinator(navigationController: navigationController,
                                           container: self)
    }
}

struct PlcaeFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private weak var placeListViewController: MainViewController?
    private let container: PlaceSceneDIContainer
    
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

    private func showPlaceDetail(place: Place) {
        let action = DetailViewModelAction(showPlaceAdd: showAddPlace)
        let vc = container.makePlaceDetailViewController(place: place, action: action)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAddPlace(with place: Place?) {
        let vc = container.makeAddPlaceViewController(with: place)
        navigationController?.pushViewController(vc, animated: true)
    }
}


