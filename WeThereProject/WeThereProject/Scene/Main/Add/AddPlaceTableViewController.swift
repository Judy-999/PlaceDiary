//
//  AddPlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/28. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift
import MobileCoreServices
import FirebaseFirestore
import GooglePlaces

protocol EditDelegate: AnyObject {
    func didEditPlace(data: Place)
}

final class AddPlaceTableViewController: UITableViewController {
    enum ViewMode {
        case add, edit
    }

    @IBOutlet weak var groupPickerView: UIPickerView!
    @IBOutlet weak var categoryPickerView: UIPickerView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var comentTextView: UITextView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var starSlider: StarRatingUISlider!
    @IBOutlet var starImageViews: [UIImageView]!
    
    private var classification = Classification()
    private var receiveImage: UIImage?, receiveName: String = ""
    private var placeGeoPoint: GeoPoint?
    private var editingPlace: Place?
    weak var editDelegate: EditDelegate?
    private var viewMode: ViewMode {
        return editingPlace == nil ? .add : .edit
    }
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    
    required init?(place: Place? = nil, viewModel: MainViewModel, coder: NSCoder) {
        self.editingPlace = place
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupPickerView()
        setupTouchevent()
        
        switch viewMode {
        case .add:
            configureTextView()
        case .edit:
            configureEditView()
        }
    }
    
    private func bind() {
        viewModel.classification
            .subscribe(onNext: { [weak self] classification in
                self?.classification = classification
            })
            .disposed(by: disposeBag)
    }
    
    func setPlaceDataFromInfo(data: Place, image: UIImage) {
        editingPlace = data
        receiveImage = image
    }
    
    private func configureTextView() {
        locationTextView.delegate = self
        locationTextView.text = PlaceInfo.locationPlaceHoler
        locationTextView.textColor = Color.placeHolder
        
        comentTextView.delegate = self
        comentTextView.text = PlaceInfo.comentPlaceHoler
        comentTextView.textColor = Color.placeHolder
    }
    
    private func setupPickerView() {
        categoryPickerView.delegate = self
        groupPickerView.delegate = self
    }
    
    private func configureEditView() {
        guard let place = editingPlace else { return }
        
        //TODO: Image load
        
        placeImageView.image = receiveImage
        nameTextField.text = place.name
        locationTextView.text = place.location
        datePicker.date = place.date
        comentTextView.text = place.coment
        rateLabel.text = place.rating
        placeGeoPoint = place.geopoint
        receiveName = place.name
        
        RatingManager().sliderStar(starImageViews,
                           rating: NSString(string: place.rating).floatValue)
        
        guard let categoryIndex = classification.category.firstIndex(of: place.category),
              let groupIndex = classification.group.firstIndex(of: place.group) else { return }
        
        categoryPickerView.selectRow(categoryIndex, inComponent: .zero, animated: false)
        groupPickerView.selectRow(groupIndex, inComponent: .zero, animated: false)
    }
    
    private func createPlace() -> Place? {
        if comentTextView.text == PlaceInfo.comentPlaceHoler {
            comentTextView.text = nil
        }
        
        guard let name = nameTextField.text,
              let location = locationTextView.text,
              let geoPoint = placeGeoPoint,
              let rate = rateLabel.text,
              let coment = comentTextView.text else { return nil }
        
        let categoryIndex = categoryPickerView.selectedRow(inComponent: .zero)
        let groupIndex = groupPickerView.selectedRow(inComponent: .zero)
        let isFavorit = editingPlace?.isFavorit ?? false

        return Place(name: name,
                     location: location,
                     date: datePicker.date,
                     isFavorit: isFavorit,
                     category: classification.category[categoryIndex],
                     rating: rate,
                     coment: coment,
                     geopoint: geoPoint,
                     group: classification.group[groupIndex])
    }

    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        let places = PlaceDataManager.shared.getPlaces()
        guard (places.first(where: { $0.name == nameTextField.text }) == nil ||
            receiveName == nameTextField.text) == true else {
            showAlert(.duplicatePlace)
           return
        }
        
        guard nameTextField.text?.isEmpty == false,
              locationTextView.text != PlaceInfo.locationPlaceHoler,
              let placeImage = placeImageView.image,
              let newPlace = createPlace() else {
            showAlert(.insufficientInput)
            return
        }
        
        switch viewMode {
        case .add:
            uploadData(place: newPlace)
            uploadImage(newPlace.name,
                        image: placeImage.resize(newWidth: 300))
        case .edit:
            if receiveName != newPlace.name {
                deletePlaceData(name: receiveName)
                //TODO: Image save
                
            }
            
            if placeImage != receiveImage || receiveName != newPlace.name {
                //TODO: Image save
                
                uploadImage(newPlace.name,
                            image: placeImage.resize(newWidth: 300))
            }
            
            uploadData(place: newPlace)
            editDelegate?.didEditPlace(data: newPlace)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func deletePlaceData(name place: String) {
        viewModel.deletePlace(place, disposeBag)
        
        //TODO: Image delete
    }

    private func uploadData(place data: Place) {
        viewModel.savePlace(data, disposeBag)
    }
    
    private func uploadImage(_ placeName: String, image: UIImage) {
        //TODO: Image save
    }
    
    @IBAction private func starSliderChanged(_ sender: Any) {
        let rating = RatingManager().sliderStar(starImageViews, rating: starSlider.value)
        rateLabel.text = rating
    }
    
    @IBAction private func addPhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

    @IBAction private func searchPositionButtonTapped(_ sender: UIButton) {
        let searchController = GMSAutocompleteViewController()
        searchController.delegate = self
        present(searchController, animated: true, completion: nil)
    }

    @IBAction private func datePick(_ sender: UIDatePicker) {
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddPlaceTableViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Color.placeHolder {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
}

// MARK: ImagePicker
extension AddPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage? = nil
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        }
        
        placeImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: GMSAutocomplete
extension AddPlaceTableViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController,
                        didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress?.replacingOccurrences(of: "대한민국 ", with: "")
        locationTextView.text = address
        locationTextView.textColor = .label
        locationTextView.isEditable = true
        placeGeoPoint = GeoPoint(latitude: place.coordinate.latitude,
                                 longitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController,
                        didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: PickerView
extension AddPlaceTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPickerView {
            return classification.category.count
        }
        return classification.group.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        if pickerView == categoryPickerView {
            return classification.category[row]
        }
        return classification.group[row]
    }
}

// MARK: Hide Keyboard
extension AddPlaceTableViewController {
    private func setupTouchevent() {
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(hideKeyboard)))
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

