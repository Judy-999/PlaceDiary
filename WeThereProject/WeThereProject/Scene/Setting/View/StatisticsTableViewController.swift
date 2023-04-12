//
//  StatisticsTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/09/12. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift

final class StatisticsTableViewController: UITableViewController {
    private let viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    
    required init?(viewModel: SettingViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaces()
        loadClassification()
        bind()
    }
    
    private func bind() {
        viewModel.classification
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupPlaces() {
        viewModel.loadPlaceData(disposeBag)
    }
    
    private func loadClassification() {
        viewModel.loadClassification(disposeBag)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = ClassificationType(rawValue: section) else { return 0 }
        let classification = viewModel.classification.value
        
        switch type {
        case .category:
            return classification.category.count
        case .group:
            return classification.group.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let type = ClassificationType(rawValue: section) else { return ClassificationType.category.title }
        return type.title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell", for: indexPath)
        guard let type = ClassificationType(rawValue: indexPath.section) else { return cell }
        let classification = viewModel.classification.value
        let places = viewModel.places.value
        
        cell.textLabel?.font = .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
      
        let title: String
        let count: Int
        
        switch type {
        case .category:
            title = classification.category[indexPath.row]
            count = places.filter { $0.category == title }.count
        case .group:
            title = classification.group[indexPath.row]
            count = places.filter { $0.group == title }.count
        }

        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "\(count) 곳"
        return cell
    }
}
