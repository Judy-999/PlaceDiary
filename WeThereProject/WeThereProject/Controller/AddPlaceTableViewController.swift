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
    var editDelegate: EditDelegate?
    var places = [Place]()
    private var viewMode: ViewMode = .add
    
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
        locationTextView.text = "이름 또는 주소로 위치를 검색하세요."
        locationTextView.textColor = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
        
        comentTextView.delegate = self
        comentTextView.text = "코멘트를 입력하세요."
        comentTextView.textColor = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
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
        let addRate = AddRate()
        
        placeImageView.image = receiveImage
        nameTextField.text = place.name
        locationTextView.text = place.location
        datePicker.date = place.date
        comentTextView.text = place.coment
        rateLabel.text = place.rate
        
        if let index = categoryItems.firstIndex(of: place.category) {
            categoryPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        if let index = groupItems.firstIndex(of: place.group) {
            categoryPickerView.selectRow(index, inComponent: 0, animated: false)
        }
       
        addRate.fill(buttons: starButtons,
                     rate: NSString(string: place.rate).floatValue)
    }
    
    private func createPlace() -> Place? {
        if comentTextView.text == "코멘트를 입력하세요." {
            comentTextView.text = ""
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
        
        if placeImageView.image == UIImage(named: "pdicon") ||
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
            myAlert("중복된 장소 이름", message: "같은 이름의 장소가 존재합니다.")
           return
        }
        
        guard nameTextField.text?.isEmpty == false,
              locationTextView.text != "위치를 입력하세요.",
              placeGeoPoint != nil else {
            myAlert("필수 입력 미기재", message: "모든 항목을 입력해주세요.")
            return
        }

        guard let newPlace = createPlace() else { return }
        
        switch viewMode {
        case .add:
            if let image = placeImageView.image {
                uploadImage(newPlace.name, image: image.resize(newWidth: 300))
            }
            
            uploadData(place: newPlace)
        case .edit:
            if let image = placeImageView.image, newPlace.hasImage == true {
                uploadImage(newPlace.name, image: image.resize(newWidth: 300))
            }
            
            if receiveName != newPlace.name {
                FirestoreManager.shared.deletePlace(receiveName)
//                deletePlaceData(name: receiveName)
            }
            
            uploadData(place: newPlace)
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
     // 장소의 이름을 변경했으면 이전 이름의 장소와 사진을 삭제하는 함수
    private func deletePlaceData(name place: String) {
         FirestoreManager.shared.deletePlace(place)
         StorageManager.shared.deleteImage(name: place)
     }
     
     // 장소 정보를 Firebase에 업로드하는 함수
    private func uploadData(place data: Place) {
         FirestoreManager.shared.savePlace(data)
    }
    
    // 선택된 이미지를 Storage에 업로드하는 함수
    private func uploadImage(_ placeName: String, image: UIImage) {
        StorageManager.shared.saveImage(image, name: placeName)
    }
    
    private func myAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func sliderChanged(_ sender: Any) {
        let addRate = AddRate()
        let starVal = starSlider.value
        addRate.sliderStar(buttons: starButtons, rate: starVal)
        
        let rateDown = starVal.rounded(.down)
        let half = starVal - rateDown
        let rateInt = Int(rateDown)
        
        if half >= 0.5{
            rateLabel.text = String(rateInt) + ".5"
        }else{
            rateLabel.text = String(rateInt) + ".0"
        }
    }
    
    @IBAction private func AddPhotoButtonTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }

    @IBAction private func searchPosition(_ sender: UIButton) {
        //구글 자동완성 뷰컨트롤러 생성
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
        if textView.textColor == #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1) {
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

extension AddPlaceTableViewController: GMSAutocompleteViewControllerDelegate { //해당 뷰컨트롤러를 익스텐션으로 딜리게이트를 달아준다.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress?.replacingOccurrences(of: "대한민국 ", with: "")
        self.locationTextView.text = address
        self.locationTextView.textColor = UIColor.label
        self.locationTextView.isEditable = true
        self.placeGeoPoint = GeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    } //원하는 셀 탭했을 때 꺼지게
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription) //에러났을 때 출력
    } //실패했을 때
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    } //캔슬버튼 눌렀을 때 화면 꺼지게
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

class StarRatingUISlider: UISlider {
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let width = self.frame.size.width
        let tapPoint = touch.location(in: self)
        let fPercent = tapPoint.x/width
        let nNewValue = self.maximumValue * Float(fPercent)
        if nNewValue != self.value {
            self.value = nNewValue
        }
        return true
    }
}
