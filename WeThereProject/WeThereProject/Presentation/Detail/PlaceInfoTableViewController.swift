//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift

final class PlaceInfoTableViewController: UITableViewController, EditDelegate {
    private var place: Place
    private let viewModel: PlaceViewModel
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var placeImage: UIImageView!
    @IBOutlet private weak var placeNameLabel: UILabel!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var groupLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var comentTextView: UITextView!
    @IBOutlet private var starImageView: [UIImageView]!
    
    required init?(place: Place, viewModel: PlaceViewModel, coder: NSCoder) {
        self.place = place
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceInfo()
        configureGesture()
    }
    
    func getPlaceInfo(_ data: Place) {
        place = data
    }
    
    func didEditPlace(data: Place) {
        getPlaceInfo(data)
        setupPlaceInfo()
        tableView.reloadData()
    }
    
    private func loadImage(with name: String) {
        viewModel.loadImage(name)
            .bind(to: placeImage.rx.image)
            .disposed(by: disposeBag)
    }
    
    private func setupPlaceInfo() {
        loadImage(with: place.name)
        
        placeNameLabel.text = place.name
        categoryLabel.text = place.category
        comentTextView.text = place.coment
        ratingLabel.text = place.rating + " 점"
        groupLabel.text = place.group
        dateLabel.text = place.date.toString
        locationButton.contentHorizontalAlignment = .left
        locationButton.setTitle(place.location, for: .normal)
        
        RatingManager().sliderStar(starImageView,
                                   rating: NSString(string: place.rating).floatValue)
    }
    
    private func configureGesture() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(imageTapped))
        placeImage.isUserInteractionEnabled = true
        placeImage.addGestureRecognizer(tap)
    }
    
    private func deletePlace(_ place: Place) {
        let deleteAlert = UIAlertController(title: PlaceInfo.Main.delete,
                                            message: place.name + PlaceInfo.Main.confirmDelete,
                                            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deletePlace(place.name, self.disposeBag)
            self.viewModel.deleteImage(place.name, self.disposeBag)
            
            var places = self.viewModel.places.value
            if let index = places.firstIndex(where: { $0.name == place.name }) {
                places.remove(at: index)
            }
            self.viewModel.places.accept(places)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        deleteAlert.addAction(Alert.cancel)
        deleteAlert.addAction(okAction)
        present(deleteAlert, animated: true)
    }
    
    @IBAction private func editButtonTapped(_ sender: UIButton) {
        let changeFavorit = place.isFavorit ? PlaceInfo.Edit.unfavorite : PlaceInfo.Edit.addFavorite
        let editAlert = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: PlaceInfo.Edit.editPlace,
                                 style: .default) { [weak self] _ in
            self?.presentEditView()
        }
        
        let favorit = UIAlertAction(title: changeFavorit, style: .default) { [self] _ in
            place.isFavorit = !(place.isFavorit)
            viewModel.savePlace(place, disposeBag)
            showAlert(changeFavorit, PlaceInfo.Edit.changeFavorit)
        }
        
        let delete = UIAlertAction(title: PlaceInfo.Edit.deletePlace,
                                   style: .destructive) { [self] _ in
            deletePlace(place)
        }
        
        [edit, favorit, delete, Alert.cancel].forEach { editAlert.addAction($0) }
        present(editAlert, animated: true)
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Segue.detailImage.identifier, sender: self)
    }
    
    private func presentEditView() {
        viewModel.showPlaceAdd(with: place)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segue.detailImage.identifier:
            let imageView = segue.destination as? ImageViewController ?? ImageViewController()
            imageView.setupImage(with: placeImage.image)
        case Segue.map.identifier:
            guard let addressController = segue.destination as? MapViewController else { return }
            addressController.onePlace = place
        default:
            break
        }
    }
}

// MARK: TableViewDataSource
extension PlaceInfoTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
}
