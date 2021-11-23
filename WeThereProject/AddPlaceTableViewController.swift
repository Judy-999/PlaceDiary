//
//  AddPlaceTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/28.
//

import UIKit
import MobileCoreServices
import FirebaseFirestore
import FirebaseStorage
import GooglePlaces

protocol EditDelegate {
    func didEditPlace(_ controller: AddPlaceTableViewController, data: PlaceData, image: UIImage)
}

class AddPlaceTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate{
    
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let imagePicker = UIImagePickerController()
    let searchController = GMSAutocompleteViewController()
    let addRate = AddRate()
    let categoryPicker = UIPickerView()
    let groupPicker = UIPickerView()
    var selectedImage: UIImage!
    var categoryItem = [String]()
    var groupItem = [String]()
    var rateButtons = [UIButton]()
    var hasImage = true
    var dataFromInfo = false
    var count = "0", reName = "", rePositon = "", reCategory = "", reRate = "", reGroup = "", reComent = ""
    var receiveImage : UIImage?
    var reDate: Date?
    var reVisit = false
    var editData: PlaceData?
    var editDelegate: EditDelegate?
    var geoPoint: GeoPoint?
    var nowPlaceData = [PlaceData]()
    
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tfPlaceName: UITextField!
    @IBOutlet var tvPlacePosition: UITextView!
    @IBOutlet var tfCategory: UITextField!
    @IBOutlet var swVisit: UISwitch!
    @IBOutlet var pkDate: UIDatePicker!
    @IBOutlet var txvComent: UITextView!
    @IBOutlet var lblVisit: UILabel!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var btnRate1: UIButton!
    @IBOutlet var btnRate2: UIButton!
    @IBOutlet var btnRate3: UIButton!
    @IBOutlet var btnRate4: UIButton!
    @IBOutlet var btnRate5: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var lbltTryCount: UILabel!
    @IBOutlet weak var tfGroup: UITextField!
    @IBOutlet weak var starSlider: StarRatingUISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imagePicker.allowsEditing = true
        
        downloadPickerItem()
        setTextView()
        
        setPicker(categoryPicker)
        setPicker(groupPicker)
        
        rateButtons.append(btnRate1)
        rateButtons.append(btnRate2)
        rateButtons.append(btnRate3)
        rateButtons.append(btnRate4)
        rateButtons.append(btnRate5)
        
        pkDate.backgroundColor = #colorLiteral(red: 0, green: 1, blue: 1, alpha: 1)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        if dataFromInfo {
            setPlaceInfo()
            txvComent.textColor = UIColor.label
            tvPlacePosition.textColor = UIColor.label
        }
    }
    
    func setPicker(_ picker: UIPickerView){ // setting picker
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
        btnPickerDone.tintColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
        btnPickerDone.target = self
        
        btnAdd.title = "추가"
        btnAdd.tintColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
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
    
    @objc func groupPickerDone(){
        if tfGroup.text == ""{
            tfGroup.text = groupItem[0]
        }
        self.view.endEditing(true)
    }
    
    @objc func categoryPickerDone(){
        if tfCategory.text == ""{
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
    
    func checkExisted(item: String, type: String) -> Bool{
        var array = categoryItem
        
        if type == "그룹"{
            array = groupItem
        }
        
        for name in array{
            if name == item{
                return false
            }
        }
        return true
    }
    
    func simpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func uploadCategory(_ type: String, item: String){
        let categoryRef = db.collection("category").document(Uid)
        var target : String!
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
    
    func setTextView(){
        txvComent.delegate = self
        tvPlacePosition.delegate = self
        txvComent.text = "코멘트를 입력하세요."
        tvPlacePosition.text = "위치를 검색하세요."
        tvPlacePosition.textColor = UIColor.lightGray
        txvComent.textColor = UIColor.lightGray
    }
    
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
    
    func setPlaceDataFromInfo(data: PlaceData, image: UIImage){
        receiveImage = image
        selectedImage = image
        reName = data.name
        rePositon = data.location
        reDate = data.date
        reCategory = data.category
        reVisit = data.visit
        reRate = data.rate
        reComent = data.coment
        geoPoint = data.geopoint
        count = data.count
        dataFromInfo = true
        reGroup = data.group
        editData = data
    }
    
    func setPlaceInfo(){
        placeImageView.image = receiveImage
        tfPlaceName.text = reName as String
        tvPlacePosition.text = rePositon
        tfCategory.text = reCategory
        swVisit.isOn = reVisit
        pkDate.date = reDate!
        txvComent.text = reComent
        lblRate.text = reRate
        lbltTryCount.text = Int(count)!.description + "회"
        stepper.value = NSString(string: count).doubleValue
        tfGroup.text = reGroup
        
        if reVisit == true{
            for btn in rateButtons{
                btn.isEnabled = true
            }
            stepper.isEnabled = true
            starSlider.isEnabled = true
            lblVisit.text = "가봤어요!"
        }else{
            for btn in rateButtons{
                btn.isEnabled = false
                btn.setImage(UIImage(systemName: "star"), for: .normal)
            }
            stepper.isEnabled = false
            starSlider.isEnabled = false
            lblRate.text = "0.0"
            lblVisit.text = "가보고 싶어요!"
        }
        addRate.fill(buttons: rateButtons, rate: NSString(string: reRate).floatValue)
    }
    
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    @IBAction func btnAddDone(_ sender: UIButton){
        let sameNamePlace = nowPlaceData.first(where: {$0.name == tfPlaceName.text})
        if sameNamePlace != nil{
            myAlert("장소 이름 중복", message: "같은 이름의 장소가 존재합니다.")
        }else if tfPlaceName.text == ""{
            myAlert("필수 입력 미기재", message: "장소의 이름을 입력해주세요.")
        }else if tvPlacePosition.text == "위치를 입력하세요."{
            myAlert("필수 입력 미기재", message: "장소의 위치를 검색해주세요.")
        }else if tfCategory.text == "" {
            myAlert("필수 입력 미기재", message: "장소의 카테고리를 선택해주세요.")
        }else if tfCategory.text == "" {
            myAlert("필수 입력 미기재", message: "장소의 그룹을 선택해주세요.")
        }else if geoPoint == nil {
            myAlert("장소 위치 선택 오류", message: "장소의 이름 또는 주소를 검색하여 선택해주세요.")
        }else if swVisit.isOn == true && count == "0"{
            myAlert("방문 횟수 미선택", message: "방문 횟수를 입력해주세요.")
        }else{
            
            if txvComent.text == "코멘트를 입력하세요."{
                txvComent.text = ""
            }
            
            uploadData()
 
            if editDelegate != nil{
                editData?.name = tfPlaceName.text!
                editData?.location = tvPlacePosition.text
                editData?.category = tfCategory.text!
                editData?.visit = swVisit.isOn
                editData?.date = pkDate.date
                editData?.coment = txvComent.text
                editData?.rate = lblRate.text!
                editData?.geopoint = geoPoint!
                editData?.count = count
                editData?.group = tfGroup.text!
                editDelegate?.didEditPlace(self, data: editData!, image: selectedImage)
            }
         
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
           
            if receiveImage == nil {
                if selectedImage == nil{
                    hasImage = false
                    uploadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                    _ = navigationController?.popViewController(animated: true)
                }else{
                    uploadImage(tfPlaceName.text!, image: selectedImage.resize(newWidth: 300))
                    editData?.newImg = selectedImage
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData)
                    hasImage = true
                }
            }else if receiveImage != selectedImage{
                if reName != tfPlaceName.text!{
                    storageRef.child(Uid + "/" + reName).delete { error in
                        if let error = error {
                            print("Error removing image: \(error)")
                        } else {
                            print("Image successfully removed!")
                        }
                      }
                }
                uploadImage(tfPlaceName.text!, image: selectedImage.resize(newWidth: 300))
                editData?.newImg = selectedImage
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData)
                hasImage = true
            }else{
                if reName != tfPlaceName.text!{
                    storageRef.child(Uid + "/" + reName).delete { error in
                        if let error = error {
                            print("Error removing image: \(error)")
                        } else {
                            print("Image successfully removed!")
                        }
                      }
                    uploadImage(tfPlaceName.text!, image: receiveImage!.resize(newWidth: 300))
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                _ = navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func uploadData(){
        if reName != "" && reName != tfPlaceName.text! {
            db.collection(Uid).document(reName).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        let docData: [String: Any] = [
            "name": tfPlaceName.text!,
            "position": tvPlacePosition.text!,
            "date": pkDate.date,
            "visit": swVisit.isOn,
            "count": count,
            "rate": lblRate.text!,
            "coment": txvComent.text!,
            "category": tfCategory.text!,
            "geopoint": geoPoint!,
            "image": hasImage,
            "group": tfGroup.text!
        ]

        db.collection(Uid).document(tfPlaceName.text!).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = nil
            textView.textColor = UIColor.label
        }
    }

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
    

    @IBAction func switchOn(_ sender: UISwitch){
        if sender.isOn == true{
            for btn in rateButtons{
                btn.isEnabled = true
            }
            lblVisit.text = "가봤어요!"
            starSlider.isEnabled = true
            stepper.isEnabled = true
        }else{
            for btn in rateButtons{
                btn.isEnabled = false
                btn.setImage(UIImage(systemName: "star"), for: .normal)
            }
            lblRate.text = "0.0"
            lblVisit.text = "가보고 싶어요!"
            starSlider.isEnabled = false
            stepper.value = 0
            lbltTryCount.text = "0회"
            stepper.isEnabled = false
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let starVal = starSlider.value
        addRate.sliderStar(buttons: rateButtons, rate: starVal)
        
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
        if(UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = true
                
            present(imagePicker, animated: true, completion: nil)
        }else{
            myAlert("갤러리 접근 불가.", message: "갤러리에 접근 할 수 없습니다.")
        }
    }
    
    @IBAction func updownStepper(_ sender: UIStepper) {
        lbltTryCount.text = Int(sender.value).description + "회"
        count = Int(sender.value).description
    }
    
    @IBAction func searchPosition(_ sender: UIButton){
        //구글 자동완성 뷰컨트롤러 생성
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
        self.geoPoint = GeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
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
