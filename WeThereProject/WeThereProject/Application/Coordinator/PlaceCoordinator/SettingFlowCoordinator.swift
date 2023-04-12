//
//  SettingFlowCoordinator.swift
//  WeThereProject
//
//  Created by 김주영 on 2023/04/12.
//

import UIKit

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
        let settingViewController = container.makeSettingViewController(with: action)
        navigationController?.pushViewController(settingViewController, animated: false)
    }
    
    private func showEditClassification(type: ClassificationType,
                                        _ viewmodel: SettingViewModel) {
        let editViewController = container.makeEditClassificationViewController(with: viewmodel, type)
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    private func showStatistics(_ viewmodel: SettingViewModel) {
        let statisticsViewController = container.makeStatisticsViewController(with: viewmodel)
        navigationController?.pushViewController(statisticsViewController, animated: true)
    }
}
