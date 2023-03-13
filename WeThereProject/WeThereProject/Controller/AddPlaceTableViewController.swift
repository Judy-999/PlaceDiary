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
    func didEditPlace(_ controller: AddPlaceTableViewController, data: Place, image: UIImage)
}

class AddPlaceTableViewController: UITableViewController {
    private enum ViewMode {
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
    private var receiveImage: UIImage?, receiveName: String = "", receiveFavofit: Bool = false
    private var placeGeoPoint: GeoPoint?
    private var editData: Place?
    private var viewMode: ViewMode = .add
    var editDelegate: EditDelegate?
    var places = [Place]()
    
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
    
    private func configureTextView() {
        locationTextView.delegate = self
        locationTextView.text = PlaceInfo.locationPlaceHoler
        locationTextView.textColor = PlaceInfo.placeHolderColor
        
        comentTextView.delegate = self
        comentTextView.text = PlaceInfo.comentPlaceHoler
        comentTextView.textColor = PlaceInfo.placeHolderColor
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

    private func simpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 편집하는 장소 데이터를 받아오는 함수
    func setPlaceDataFromInfo(data: Place, image: UIImage) {
        editData = data
        receiveImage = image
    }
    
    private func configureEditView() {
        guard let place = editData else { return }
        let addRate = RatingManager()
        
        placeImageView.image = receiveImage
        nameTextField.text = place.name
        locationTextView.text = place.location
        datePicker.date = place.date
        comentTextView.text = place.coment
        rateLabel.text = place.rate
        
        addRate.sliderStar(starButtons,
                           rating: NSString(string: place.rate).floatValue)
        
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
        var hasImage = true
        
        if placeImageView.image == DiaryImage.placeholer ||
            placeImageView.image == nil {
            hasImage = false
        }
        
        return Place(name: name,
                     location: location,
                     date: datePicker.date,
                     isFavorit: isFavorit,
                     hasImage: hasImage,
                     category: categoryItems[categoryIndex],
                     rate: rate,
                     coment: coment,
                     geopoint: geoPoint,
                     group: groupItems[groupIndex])
    }

    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        guard places.first(where: { $0.name == nameTextField.text }) == nil else {
            showAlert(.duplicatePlace)
           return
        }
        
        guard nameTextField.text?.isEmpty == false,
              locationTextView.text != PlaceInfo.locationPlaceHoler,
              placeGeoPoint != nil,
              let newPlace = createPlace() else {
            showAlert(.insufficientInput)
            return
        }
        
        switch viewMode {
        case .add:
            if let image = placeImageView.image {
                uploadImage(newPlace.name,
                            image: image.resize(newWidth: 300))
            }
            
            uploadData(place: newPlace)
        case .edit:
            if let image = placeImageView.image, newPlace.hasImage == true {
                uploadImage(newPlace.name,
                            image: image.resize(newWidth: 300))
            }
            
            if receiveName != newPlace.name {
                FirestoreManager.shared.deletePlace(receiveName)
//                deletePlaceData(name: receiveName)
            }
            
            uploadData(place: newPlace)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func deletePlaceData(name place: String) {
         FirestoreManager.shared.deletePlace(place)
         StorageManager.shared.deleteImage(name: place)
     }

    private func uploadData(place data: Place) {
         FirestoreManager.shared.savePlace(data)
    }
    
    private func uploadImage(_ placeName: String, image: UIImage) {
        StorageManager.shared.saveImage(image, name: placeName)
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
        if textView.textColor == PlaceInfo.placeHolderColor {
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }
}

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

extension AddPlaceTableViewController :  UIPickerViewDelegate, UIPickerViewDataSource {
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
