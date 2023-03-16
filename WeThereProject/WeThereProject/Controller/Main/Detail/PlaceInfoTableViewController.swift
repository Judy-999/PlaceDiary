//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06. --> Refacted on 2022/12/15
//

import UIKit

protocol ImageDelegate {
    func didImageDone(newData: Place, image: UIImage)
}

final class PlaceInfoTableViewController: UITableViewController, EditDelegate {
    private var receiveImage: UIImage?
    private var place: Place?
    var imgDelegate : ImageDelegate?
    
    @IBOutlet private weak var placeImage: UIImageView!
    @IBOutlet private weak var placeNameLabel: UILabel!
    @IBOutlet private weak var locationButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var groupLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var comentTextView: UITextView!
    @IBOutlet private var rateButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlaceInfo()
        configureGesture()
    }
    
    func getPlaceInfo(_ data: Place) {
        place = data
    }
    
    func didEditPlace(_ controller: AddPlaceTableViewController, data: Place, image: UIImage) {
        getPlaceInfo(data)
        setupPlaceInfo()
        tableView.reloadData()
    }
    
    private func setupPlaceInfo() {
        guard let place = place else { return }
        
        ImageCacheManager.shared.setupImage(with: place.name) { [weak self] image in
            DispatchQueue.main.async {
                self?.placeImage.image = image
            }
            
            self?.receiveImage = image
        }
        
        placeNameLabel.text = place.name
        categoryLabel.text = place.category
        comentTextView.text = place.coment
        ratingLabel.text = place.rate + " 점"
        groupLabel.text = place.group
        dateLabel.text = place.date.toString
        locationButton.contentHorizontalAlignment = .left
        locationButton.setTitle(place.location, for: .normal)
        
        RatingManager().sliderStar(rateButtons,
                                   rating: NSString(string: place.rate).floatValue)
    }
    
    private func configureGesture() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(imageTapped))
        placeImage.isUserInteractionEnabled = true
        placeImage.addGestureRecognizer(tap)
    }
    
    @IBAction private func editButtonTapped(_ sender: UIButton) {
        guard var place = place else { return }
        let changeFavorit = place.isFavorit ? PlaceInfo.Edit.unfavorite :  PlaceInfo.Edit.addFavorite
        let editAlert = UIAlertController(title: nil,
                                          message: nil,
                                          preferredStyle: .actionSheet)
        
        
        let edit = UIAlertAction(title: PlaceInfo.Edit.editPlace,
                                 style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: Segue.edit.identifier, sender: self)
        }
        
        let delete = UIAlertAction(title: PlaceInfo.Edit.deletePlace,
                                   style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"),
                                            object: place)
        }
        
        let favorit = UIAlertAction(title: changeFavorit, style: .default){ [weak self] _ in
            let changedFavorit = !(place.isFavorit)
            
            place.isFavorit = changedFavorit
            FirestoreManager.shared.updateFavorit(changedFavorit, placeName: place.name)
            
            self?.showAlert(changeFavorit, PlaceInfo.Edit.changeFavorit)
            
        }
        
        let cancel = UIAlertAction(title: PlaceInfo.Edit.cancel,
                                   style: .destructive)
        [edit, delete, favorit, cancel].forEach { editAlert.addAction($0) }
        
        present(editAlert, animated: true)
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: Segue.detailImage.identifier, sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segue.edit.identifier:
            let addPlaceViewController = segue.destination as? AddPlaceTableViewController ?? AddPlaceTableViewController()
            addPlaceViewController.editDelegate = self
            addPlaceViewController.setPlaceDataFromInfo(data: place!,
                                                        image: receiveImage!)
        case Segue.detailImage.identifier:
            let imageView = segue.destination as? ImageViewController ?? ImageViewController()
            imageView.fullImage = placeImage.image
        case Segue.map.identifier:
            let addressController = segue.destination as? MapViewController ?? MapViewController()
            addressController.onePlace = place
        default:
            break
        }
    }
}

// MARK: - Table view data source
extension PlaceInfoTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && place?.hasImage == false {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}
