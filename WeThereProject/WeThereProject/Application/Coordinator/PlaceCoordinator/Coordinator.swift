//
//  Coordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    var container: PlaceSceneDIContainer { get }
    func start()
}

extension Coordinator {
    func showPlaceDetail(with place: Place, _ viewModel: PlaceViewModel) {
        let detailViewController = container.makePlaceDetailViewController(place, viewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func showAddPlace(with place: Place?, _ viewModel: DefaultViewModelType) {
        let addPlaceViewController = container.makeAddPlaceViewController(with: place, viewModel)
        navigationController?.pushViewController(addPlaceViewController, animated: true)
    }
}
