//
//  AddPlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/28. --> Refacted on 2022/12/15
//

import UIKit
import MobileCoreServices
import FirebaseFirestore
import FirebaseStorage
import GooglePlaces

protocol EditDelegate {
    func didEditPlace(_ controller: AddPlaceTableViewController, data: Place, image: UIImage)
}

class AddPlaceTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate{
    
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let categoryPicker = UIPickerView(), groupPicker = UIPickerView()
    var categoryItem = [String](), groupItem = [String]()
    var starButtons = [UIButton]()
    var hasImage: Bool = true
    var dataFromInfo: Bool = false
    var selectedImage: UIImage!
    var receiveImage: UIImage?, receiveName: String = "", receiveFavofit: Bool = false
    var placeHasImg: Bool = false
    var visitCount = "0"
    var placeGeoPoint: GeoPoint?
    var editData: Place?
    var editDelegate: EditDelegate?
    var nowPlaceData = [Place]()
    
    @IBOutlet var btnGallery: UIButton!
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tfPlaceName: UITextField!
    @IBOutlet var tvPlacePosition: UITextView!
    @IBOutlet var tfCategory: UITextField!
    @IBOutlet var pkDate: UIDatePicker!
    @IBOutlet var txvComent: UITextView!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var btnRate1: UIButton!
    @IBOutlet var btnRate2: UIButton!
    @IBOutlet var btnRate3: UIButton!
    @IBOutlet var btnRate4: UIButton!
    @IBOutlet var btnRate5: UIButton!
    @IBOutlet weak var tfGroup: UITextField!
    @IBOutlet weak var starSlider: StarRatingUISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        downloadPickerItem()
        setPicker(categoryPicker)
        setPicker(groupPicker)
        
        txvComent.delegate = self
        tvPlacePosition.delegate = self
        txvComent.text = "코멘트를 입력하세요."
        tvPlacePosition.text = "이름 또는 주소로 위치를 검색하세요."
        tvPlacePosition.textColor = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
        txvComent.textColor = #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1)
        
        btnGallery.layer.borderWidth = 1
        btnGallery.layer.borderColor = UIColor.lightGray.cgColor
        
        starButtons.append(btnRate1)
        starButtons.append(btnRate2)
        starButtons.append(btnRate3)
        starButtons.append(btnRate4)
        starButtons.append(btnRate5)

        tableView.tableFooterView = UIView(frame: CGRect.zero)
      
        if dataFromInfo {
            setPlaceInfo()
            txvComent.textColor = UIColor.label
            tvPlacePosition.textColor = UIColor.label
            tvPlacePosition.isEditable = true
        }
    }
    
    // Picker 설정
    func setPicker(_ picker: UIPickerView){
        let pickerToolbar = UIToolbar()
        let btnPickerDone = UIBarButtonItem()
        let btnAdd = UIBarButtonItem()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let picker = picker
        
        picker.backgroundColor = UIColor.clear
        picker.frame = CGRect(x: 0, y: 0, width: 0, height: 200)
        pickerToolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 40)
        pickerToolbar.barTintColor = UIColor.white
        
        btnPickerDone.title = "선택"
        btnPickerDone.tintColor = #colorLiteral(red: 0.2113277912, green: 0.9666495919, blue: 0.9550952315, alpha: 1)
        btnPickerDone.target = self
        
        btnAdd.title = "추가"
        btnAdd.tintColor = #colorLiteral(red: 0.2113277912, green: 0.9666495919, blue: 0.9550952315, alpha: 1)
        btnAdd.target = self
        
        pickerToolbar.setItems([btnAdd, flexSpace, btnPickerDone], animated: true)
        picker.delegate = self
        
        if picker == categoryPicker{
            self.tfCategory.inputAccessoryView = pickerToolbar
            btnPickerDone.action = #selector(categoryPickerDone)
            btnAdd.action = #selector(editCategory)
            picker.tag = 0
            self.tfCategory.inputView = picker
        }else{
            self.tfGroup.inputAccessoryView = pickerToolbar
            btnPickerDone.action = #selector(groupPickerDone)
            btnAdd.action = #selector(editGroup)
            picker.tag = 1
            self.tfGroup.inputView = picker
        }
    }
    
    // 그룹 선택 완료
    @objc func groupPickerDone(){
        if tfGroup.text == "그룹 선택"{
            tfGroup.text = groupItem[0]
        }
        self.view.endEditing(true)
    }
    
    // 문류 선택 완료
    @objc func categoryPickerDone(){
        if tfCategory.text == "분류 선택"{
            tfCategory.text = categoryItem[0]
        }
        self.view.endEditing(true)
    }
    
    @objc func editCategory(){
        addNewCategory("분류")
    }
    
    @objc func editGroup(){
        addNewCategory("그룹")
    }
    
    // 새로운 분류 or 그룹을 바로 추가하는 함수
    func addNewCategory(_ type: String){
        let addAlert = UIAlertController(title: type + " 추가", message: "새로운 항목을 입력하세요.", preferredStyle: .alert)
        addAlert.addTextField()
        let alertOk = UIAlertAction(title: "추가", style: .default) { [self] (alertOk) in
            if let newItem = addAlert.textFields?[0].text{
                if checkExisted(item: newItem, type: type){
                    uploadCategory(type, item: newItem)
                }else{
                    simpleAlert(title: "생성 불가", message: "이미 존재하는 항목입니다.")
                }
            }else{
                simpleAlert(title: "생성 불가", message: "생성할 이름을 입력해주세요")
            }
        }
        addAlert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        addAlert.addAction(alertOk)
        self.present(addAlert, animated: true, completion: nil)
    }
    
    // 새로 추가하려는 분류나 그룹이 이미 존재하는지 확인하는 함수
    func checkExisted(item: String, type: String) -> Bool{
        var checkList = [String]()
        type == "그룹" ? (checkList = groupItem) : (checkList = categoryItem)
        let sameName = checkList.filter({$0 == item})
        return sameName.count == 0 ? true : false
    }
    
    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 새로 추가한 분류나 그룹을 Firebase에 올리는 함수
    func uploadCategory(_ type: String, item: String){
        let categoryRef = db.collection("category").document(Uid)
        var target: String!
        var array = [String]()
        
        if type == "분류"{
            target = "items"
            categoryItem.append(item)
            array = categoryItem
            categoryPicker.reloadAllComponents()
        }else{
            target = "group"
            groupItem.append(item)
            array = groupItem
            groupPicker.reloadAllComponents()
        }
        categoryRef.updateData([
            target : array
        ])
    }

    
    // 분류와 그룹 리스트를 Firebase에서 받아오는 함수
    func downloadPickerItem(){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.categoryItem = (document.get("items") as? [String])!
                self.groupItem = (document.get("group") as? [String])!
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // 편집하는 장소 데이터를 받아오는 함수
    func setPlaceDataFromInfo(data: Place, image: UIImage){
        editData = data
        receiveImage = image
        selectedImage = image
        dataFromInfo = true
        receiveName = data.name
        receiveFavofit = data.isFavorit
        placeHasImg = data.hasImage
        placeGeoPoint = data.geopoint
    }
    
    // 편집할 장소 데이터로 정보창을 설정하는 함수
    func setPlaceInfo(){
        let addRate = AddRate()
        
        placeImageView.image = receiveImage
        tfPlaceName.text = editData?.name
        tvPlacePosition.text = editData?.location
        tfCategory.text = editData?.category
        pkDate.date = editData!.date
        txvComent.text = editData?.coment
        lblRate.text = editData?.rate
        tfGroup.text = editData?.group
        
        addRate.fill(buttons: starButtons, rate: NSString(string: editData!.rate).floatValue)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    @IBAction func btnAddDone(_ sender: UIButton){
        guard nowPlaceData.first(where: {$0.name == tfPlaceName.text}) == nil else {
            myAlert("장소 이름 중복", message: "같은 이름의 장소가 존재합니다.")
           return
        }
        
        guard tfPlaceName.text != "", tvPlacePosition.text != "위치를 입력하세요.", tfCategory.text != "", tfGroup.text != "", placeGeoPoint != nil else {
            myAlert("필수 입력 미기재", message: "모든 항목을 입력해주세요.")
            return
        }
                    
        // 코멘트를 입력하지 않은 상태면 코멘트는 빈칸으로 저장
        if txvComent.text == "코멘트를 입력하세요."{
            txvComent.text = "내용 없음"
        }

        var newPlaceInfo: Place = Place(name: tfPlaceName.text!, location: tvPlacePosition.text, date: pkDate.date, isFavorit: receiveFavofit, hasImage: placeHasImg, category: tfCategory.text!, rate: lblRate.text!, coment: txvComent.text, geopoint: placeGeoPoint!, group: tfGroup.text!, newImg: nil)
        
        if editDelegate != nil{ // 장소를 편집하는 중이라면
            if placeHasImg == false{ // 원래 사진이 없을 때
                print("저한테 듷어오긴 하나요>>>>")
                if selectedImage != UIImage(named: "pdicon"){    // 새로 사진을 선택했을 때
                    newPlaceInfo.hasImage = true
                    uploadImage(newPlaceInfo.name, image: selectedImage.resize(newWidth: 300))
                    newPlaceInfo.newImg = selectedImage
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: newPlaceInfo)
                }else{  // 새로 사진이 없을 때
                    newPlaceInfo.hasImage = false
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                }
                uploadData(place: newPlaceInfo)
            }else{  // 원래 사진이 있을 때
                newPlaceInfo.hasImage = true
                uploadData(place: newPlaceInfo)
                if receiveImage != selectedImage{   // 새로운 사진으로 변경했을 때
                    uploadImage(newPlaceInfo.name, image: selectedImage.resize(newWidth: 300))
                    if receiveName != newPlaceInfo.name{    // 이름을 변경했을 때
                        deletePlaceData(name: receiveName)
                    }
                    newPlaceInfo.newImg = selectedImage
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: newPlaceInfo)
                }else{  // 사진이 변경되지 않았을 때
                    if receiveName != newPlaceInfo.name{    // 이름을 변경했을 때
                        uploadImage(newPlaceInfo.name, image: selectedImage.resize(newWidth: 300))
                        deletePlaceData(name: receiveName)
                        newPlaceInfo.newImg = receiveImage
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: newPlaceInfo)
                    }else{  // 이름을 변경하지 않았을 때
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                    }
                }
            }
            editDelegate?.didEditPlace(self, data: newPlaceInfo, image: selectedImage)  // 장소 정보 페이지로 변경된 장소 정보 보내주기
        }else{  // 새로운 장소 추가
            if selectedImage == nil{    // 선택한 이미지 없음
                newPlaceInfo.hasImage = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
            }else{  // 선택한 이미지 있음
                newPlaceInfo.hasImage = true
                uploadImage(newPlaceInfo.name, image: selectedImage.resize(newWidth: 300))
                newPlaceInfo.newImg = selectedImage
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: newPlaceInfo)
            }
            uploadData(place: newPlaceInfo)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
     // 장소의 이름을 변경했으면 이전 이름의 장소와 사진을 삭제하는 함수
     func deletePlaceData(name place: String){
         db.collection(Uid).document(place).delete() { err in
             if let err = err {
                 print("Error removing document: \(err)")
             } else {
                 print("Document successfully removed!")
             }
         }
         storageRef.child(Uid + "/" + place).delete { error in
             if let error = error {
                 print("Error removing image: \(error)")
             } else {
                 print("Image successfully removed!")
             }
         }
     }
     
     // 장소 정보를 Firebase에 업로드하는 함수
     func uploadData(place data: Place){
         let docData: [String: Any] = [
            "name": data.name,
            "position": data.location,
            "date": data.date,
            "favorit": data.isFavorit,
            "rate": data.rate,
            "coment": data.coment,
            "category": data.category,
            "geopoint": data.geopoint,
            "image": data.hasImage,
            "group": data.group
        ]

        db.collection(Uid).document(tfPlaceName.text!).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // 선택된 이미지를 Storage에 업로드하는 함수
    func uploadImage(_ path: String, image: UIImage){
        let original = image
        var data = Data()
        data = original.jpegData(compressionQuality: 0.8)!
        let filePath = path
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.child(Uid + "/" + filePath).putData(data, metadata: metaData){
            (metaData, error) in if let error = error{
                print(error.localizedDescription)
                return
            }else{
                _ = self.navigationController?.popViewController(animated: true)
                print("Image successfully upload!")
            }
        }
    }
    
    // TextView 편집을 시작하면 글자 색상을 변경하는 함수
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.768627286, green: 0.7686277032, blue: 0.7772355676, alpha: 1){
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }

    // 이미지 선택하는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImage = img
        }else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImage = img //사진을 가져와 라이브러리에 저장
        }
        placeImageView.image = selectedImage
        self.dismiss(animated: true, completion: nil)   //현재 뷰 컨트롤러 제거
    }
        
    //사용자가 사진이나 비디오를 찍지 않고 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)   //이미지 피커를 제거하고 초기 뷰를 보여줌
    }
    
    
    func myAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let addRate = AddRate()
        let starVal = starSlider.value
        addRate.sliderStar(buttons: starButtons, rate: starVal)
        
        let rateDown = starVal.rounded(.down)
        let half = starVal - rateDown
        let rateInt = Int(rateDown)
        
        if half >= 0.5{
            lblRate.text = String(rateInt) + ".5"
        }else{
            lblRate.text = String(rateInt) + ".0"
        }
    }
    
    @IBAction func btnAddPhoto(_ sender: UIButton){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }else{
            myAlert("갤러리 접근 불가", message: "갤러리에 접근 할 수 없습니다.")
        }
    }
    

    @IBAction func searchPosition(_ sender: UIButton){
        //구글 자동완성 뷰컨트롤러 생성
        let searchController = GMSAutocompleteViewController()
        searchController.delegate = self
        present(searchController, animated: true, completion: nil)
    }

    @IBAction func datePick(_ sender: UIDatePicker){
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}


extension AddPlaceTableViewController: GMSAutocompleteViewControllerDelegate { //해당 뷰컨트롤러를 익스텐션으로 딜리게이트를 달아준다.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = place.formattedAddress?.replacingOccurrences(of: "대한민국 ", with: "")
        self.tvPlacePosition.text = address
        self.tvPlacePosition.textColor = UIColor.label
        self.tvPlacePosition.isEditable = true
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

extension UIImage {
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image {
            context in self.draw(in: CGRect(origin: .zero, size: size)) }
        return renderImage
    }
}

extension AddPlaceTableViewController :  UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return categoryItem.count
        }else{
            return groupItem.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return categoryItem[row]
        }else{
            return groupItem[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0{
            tfCategory.text = categoryItem[row]
        }else{
            return tfGroup.text = groupItem[row]
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
