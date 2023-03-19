//
//  AddPlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/28. --> Refacted on 2022/12/15
//

import UIKit
import MobileCoreServices
import FirebaseFirestore
import GooglePlaces

protocol EditDelegate {
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
    @IBOutlet var starButtons: [UIButton]!
    
    private var categoryItems = [String](), groupItems = [String]()
    private var receiveImage: UIImage?, receiveName: String = ""
    private var placeGeoPoint: GeoPoint?
    private var editData: Place?
    var viewMode: ViewMode = .add
    var editDelegate: EditDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadClassification()
        
        switch viewMode {
        case .add:
            configureTextView()
        case .edit:
            configureEditView()
        }
    }
    
    func setPlaceDataFromInfo(data: Place, image: UIImage) {
        editData = data
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
    
    private func loadClassification() {
        FirestoreManager.shared.loadClassification { categoryItems, groupItems in
            self.categoryItems = categoryItems
            self.groupItems = groupItems
            self.setupPickerView()
        }
    }
    
    private func setupPickerView() {
        categoryPickerView.delegate = self
        groupPickerView.delegate = self
    }
    
    private func configureEditView() {
        guard let place = editData else { return }
        let addRate = RatingManager()
        
        placeImageView.image = receiveImage
        nameTextField.text = place.name
        locationTextView.text = place.location
        datePicker.date = place.date
        comentTextView.text = place.coment
        rateLabel.text = place.rating
        placeGeoPoint = place.geopoint
        receiveName = place.name
        
        addRate.sliderStar(starButtons,
                           rating: NSString(string: place.rating).floatValue)
        
        guard let categoryIndex = categoryItems.firstIndex(of: place.category),
              let groupIndex = groupItems.firstIndex(of: place.group) else { return }
        
        categoryPickerView.selectRow(categoryIndex, inComponent: 0, animated: false)
        groupPickerView.selectRow(groupIndex, inComponent: 0, animated: false)
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
        
        let categoryIndex = categoryPickerView.selectedRow(inComponent: 0)
        let groupIndex = groupPickerView.selectedRow(inComponent: 0)
        let isFavorit = editData?.isFavorit ?? false

        return Place(name: name,
                     location: location,
                     date: datePicker.date,
                     isFavorit: isFavorit,
                     category: categoryItems[categoryIndex],
                     rating: rate,
                     coment: coment,
                     geopoint: geoPoint,
                     group: groupItems[groupIndex])
    }

    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        let places = PlaceDataManager.shared.getPlaces()
        guard places.first(where: { $0.name == nameTextField.text }) == nil else {
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
                ImageCacheManager.shared.updateImage(with: receiveName,
                                                     new: newPlace.name, placeImage)
            }
            
            if placeImage != receiveImage || receiveName != newPlace.name {
                ImageCacheManager.shared.updateImage(with: receiveName,
                                                     new: newPlace.name, placeImage)
                uploadImage(newPlace.name,
                            image: placeImage.resize(newWidth: 300))
            }
            
            uploadData(place: newPlace)
            editDelegate?.didEditPlace(data: newPlace)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    private func deletePlaceData(name place: String) {
        FirestoreManager.shared.deletePlace(place)
        StorageManager.shared.deleteImage(name: place) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                self?.showAlert("실패", failure.errorDescription)
            }
        }
    }

    private func uploadData(place data: Place) {
         FirestoreManager.shared.savePlace(data)
    }
    
    private func uploadImage(_ placeName: String, image: UIImage) {
        StorageManager.shared.saveImage(image, name: placeName) { [weak self] result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                self?.showAlert("실패", failure.errorDescription)
            }
        }
    }
    
    @IBAction private func starSliderChanged(_ sender: Any) {
        let rating = RatingManager().sliderStar(starButtons, rating: starSlider.value)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage? = nil
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        }
        
        placeImageView.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)  
    }
}

// MARK: GMSAutocomplete
extension AddPlaceTableViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress?.replacingOccurrences(of: "대한민국 ", with: "")
        self.locationTextView.text = address
        self.locationTextView.textColor = UIColor.label
        self.locationTextView.isEditable = true
        self.placeGeoPoint = GeoPoint(latitude: place.coordinate.latitude,
                                      longitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPickerView {
            return categoryItems.count
        } else {
            return groupItems.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPickerView {
            return categoryItems[row]
        } else {
            return groupItems[row]
        }
    }
}

final class StarRatingUISlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let tapPercent = tapPoint.x / width
        let newValue = self.maximumValue * Float(tapPercent)
        
        if newValue != self.value {
            self.value = newValue
        }
        
        return true
    }
}
