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

class AddPlaceTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate{
    
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
    
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var selectedImage: UIImage!
    let PICKER_VIEW_COLUMN = 1
    let searchController = GMSAutocompleteViewController()
    var categoryItem = [String]()
    var groupItem = [String]()
    var rateButtons = [UIButton]()
    let rate = AddRate()
    var isImage = true
    var dataFromInfo = false
    var count = "0"
    var receiveImage : UIImage?
    var reName = ""
    var rePositon = ""
    var reDate: Date?
    var reCategory = ""
    var reVisit = false
    var reRate = ""
    var reComent = ""
    var reGroup = ""
    var editData: PlaceData?
    var editDelegate: EditDelegate?
    var geoPoint: GeoPoint?
    var nowPlaceData = [PlaceData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        downloadPickerItem()
        setTextView()
        setPickerView()
        setGroupPicker()
        
        rateButtons.append(btnRate1)
        rateButtons.append(btnRate2)
        rateButtons.append(btnRate3)
        rateButtons.append(btnRate4)
        rateButtons.append(btnRate5)
    
        if dataFromInfo {
            setPlaceInfo()
            txvComent.textColor = UIColor.black
            tvPlacePosition.textColor = UIColor.black
        }
    }
    
    func setPickerView(){
        let categoryPicker = UIPickerView()
        let pickerToolbar = UIToolbar()
        let btnPickerDone = UIBarButtonItem()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        pickerToolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        pickerToolbar.barTintColor = UIColor.white
        self.tfCategory.inputAccessoryView = pickerToolbar
        
        btnPickerDone.title = "선택"
        btnPickerDone.target = self
        btnPickerDone.action = #selector(pickerDone)
        
        pickerToolbar.setItems([flexSpace, btnPickerDone], animated: true)
        
        categoryPicker.tag = 0
        categoryPicker.delegate = self
        self.tfCategory.inputView = categoryPicker
    }
    
    func setGroupPicker(){
        let groupPicker = UIPickerView()
        let groupToolbar = UIToolbar()
        let btnPickerDone = UIBarButtonItem()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        groupToolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
        groupToolbar.barTintColor = UIColor.white
        self.tfGroup.inputAccessoryView = groupToolbar
        
        btnPickerDone.title = "선택"
        btnPickerDone.target = self
        btnPickerDone.action = #selector(pickerDone)
        
        
        groupToolbar.setItems([flexSpace, btnPickerDone], animated: true)
        
        groupPicker.tag = 1
        groupPicker.delegate = self
        self.tfGroup.inputView = groupPicker
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
            lblVisit.text = "가봤어요!"
        }else{
            for btn in rateButtons{
                btn.isEnabled = false
                btn.setImage(UIImage(systemName: "star"), for: .normal)
            }
            lblRate.text = "0.0"
            lblVisit.text = "가보고 싶어요!"
        }
        rate.fill(buttons: rateButtons, rate: NSString(string: reRate).floatValue)
    }
    
    @objc func pickerDone(){
        self.view.endEditing(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    @IBAction func btnAddDone(_ sender: UIButton){
        let i = nowPlaceData.first(where: {$0.name == tfPlaceName.text})
        if i != nil{
            myAlert("장소 이름 중복", message: "같은 이름의 장소가 존재합니다.")
        }else if tfPlaceName.text == ""{
            myAlert("필수 입력 미기재", message: "장소의 이름을 입력해주세요.")
        }else if tvPlacePosition.text == "위치를 입력하세요."{
            myAlert("필수 입력 미기재", message: "장소의 위치를 입력해주세요.")
        }else if tfCategory.text == "" {
            myAlert("필수 입력 미기재", message: "장소의 카테고리를 선택해주세요.")
        }else if tfCategory.text == "" {
            myAlert("필수 입력 미기재", message: "장소의 그룹을 선택해주세요.")
        }else if geoPoint == nil {
            myAlert("장소 위치 선택 오류", message: "장소의 이름 또는 주소를 검색하여 선택해주세요.")
        }else{
            //    tfPlaceName.placeholder = "이름을 입력하세요."
            
            if txvComent.text == "코멘트를 입력하세요."{
                txvComent.text = ""
            }
            
            if tfGroup.text == ""{
                tfGroup.text = "기본"
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
                    isImage = false
                    uploadData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                    _ = navigationController?.popViewController(animated: true)
                }else{
                    uploadImage(tfPlaceName.text!, image: selectedImage.resize(newWidth: 300))
                    editData?.newImg = selectedImage
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData)
                  //  placeImages.updateValue(selectedImage, forKey: tfPlaceName.text!)
                    isImage = true
                }
            }else if receiveImage != selectedImage{
                uploadImage(tfPlaceName.text!, image: selectedImage.resize(newWidth: 300))
               // placeImages.updateValue(selectedImage, forKey: tfPlaceName.text!)
                editData?.newImg = selectedImage
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData)
                isImage = true
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: nil)
                _ = navigationController?.popViewController(animated: true)
            }
             
          //  _ = navigationController?.popViewController(animated: true)
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
            "date": pkDate.date,  //Timestamp(date: Date()),
            "visit": swVisit.isOn,
            "count": count,
            "rate": lblRate.text!,
            "coment": txvComent.text!,
            "category": tfCategory.text!,
            "geopoint": geoPoint!,
            "image": isImage,
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
            textView.textColor = UIColor.black
        }
    }
    /*
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "코멘트를 입력하세요."
            textView.textColor = UIColor.lightGray
        }
    }
*/
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PICKER_VIEW_COLUMN
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage //사진을 가져와 라이브러리에 저장

        placeImageView.image = selectedImage
        
      //  placeImageView.image = selectedImage.resize(newWidth: 10)
   
     //   selectedImage = selectedImage.resize(newWidth: 50)
        
        self.dismiss(animated: true, completion: nil)   //현재 뷰 컨트롤러 제거
    }
        
    //사용자가 사진이나 비디오를 찍지 않고 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)   //이미지 피커를 제거하고 초기 뷰를 보여줌
    }
        
    
    //경고 표시
    func myAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
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
    
 /*   @IBAction func clickStar(_ sender: UIButton){
        lblRate.text = String(describing: rate.checkAttr(buttons: rateButtons, button: sender))
    }
    
 */
    
    @IBAction func sliderChanged(_ sender: Any) {
        let starVal = starSlider.value
        rate.sliderStar(buttons: rateButtons, rate: starVal)
        
        
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
            myAlert("Photo album inaccessable", message: "Application cannot access the photo album.")
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

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AddPlaceTableViewController: GMSAutocompleteViewControllerDelegate { //해당 뷰컨트롤러를 익스텐션으로 딜리게이트를 달아준다.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    //     print("Place name: \(String(describing: place.name))") //셀탭한 글씨출력
        let address = place.formattedAddress?.replacingOccurrences(of: "대한민국 ", with: "")
        self.tvPlacePosition.text = address
        self.tvPlacePosition.textColor = UIColor.black
        self.tvPlacePosition.isEditable = true
        self.geoPoint = GeoPoint(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        dismiss(animated: true, completion: nil) //화면꺼지게
        
    } //원하는 셀 탭했을 때 꺼지게
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)//에러났을 때 출력
    } //실패했을 때
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil) //화면 꺼지게
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
    //    print("화면 배율: \(UIScreen.main.scale)")// 배수
    //    print("origin: \(self), resize: \(renderImage)")
     //   printDataSize(renderImage)
        
        return renderImage
    }
    
    func downSample2(size: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let data = self.pngData()! as CFData
        let imageSource = CGImageSourceCreateWithData(data, imageSourceOption)!
        let maxPixel = max(size.width, size.height) * scale
        let downSampleOptions = [ kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceShouldCacheImmediately: true,
                                  kCGImageSourceCreateThumbnailWithTransform: true, kCGImageSourceThumbnailMaxPixelSize: maxPixel ] as CFDictionary
        let downSampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downSampleOptions)!
        let newImage = UIImage(cgImage: downSampledImage)
        print("origin: \(self), resize: \(newImage)")
        return newImage
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
