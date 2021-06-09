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

protocol EditDelegate {
    func didEditPlace(_ controller: AddPlaceTableViewController, data: PlaceData, image: UIImage)
}


class AddPlaceTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var tfPlaceName: UITextField!
    @IBOutlet var tfPlacePosition: UITextField!
    @IBOutlet var tfCategory: UITextField!
    @IBOutlet var swVisit: UISwitch!
    @IBOutlet var pkDate: UIDatePicker!
    @IBOutlet var txvComent: UITextView!
    @IBOutlet var lblRate: UILabel!
    @IBOutlet var btnRate1: UIButton!
    @IBOutlet var btnRate2: UIButton!
    @IBOutlet var btnRate3: UIButton!
    @IBOutlet var btnRate4: UIButton!
    @IBOutlet var btnRate5: UIButton!
    
    
    let db: Firestore = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var selectedImage: UIImage!
    let PICKER_VIEW_COLUMN = 1
    var category = ["음식점", "카페", "술집", "액티비티", "야외"]
    var rateButtons = [UIButton]()
    let rate = AddRate()
    var fromInfo = false
    var receiveImage : UIImage?
    var reName = ""
    var rePositon = ""
    var reDate : Date?
    var reCategory = ""
    var reVisit = false
    var reRate = ""
    var reComent = ""
    var editData : PlaceData?
    var delegate : EditDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let categoryPicker = UIPickerView()
        let pickerToolbar = UIToolbar()
        let btnPickerDone = UIBarButtonItem()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        pickerToolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 35)
      //  pickerToolbar.barTintColor = UIColor.lightGray
        self.tfCategory.inputAccessoryView = pickerToolbar
        
        btnPickerDone.title = "Done"
        btnPickerDone.target = self
        btnPickerDone.action = #selector(pickerDone)
        
        pickerToolbar.setItems([flexSpace, btnPickerDone], animated: true)
        
        categoryPicker.delegate = self
        self.tfCategory.inputView = categoryPicker
 
        

        rateButtons.append(btnRate1)
        rateButtons.append(btnRate2)
        rateButtons.append(btnRate3)
        rateButtons.append(btnRate4)
        rateButtons.append(btnRate5)
        
        if fromInfo {
            set()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func setInfo(data: PlaceData, image: UIImage){
        receiveImage = image
        selectedImage = image
        reName = data.name!
        rePositon = data.position!
        reDate = data.date!
        reCategory = data.category!
        reVisit = data.visit!
        reRate = data.rate!
        reComent = data.coment!
        fromInfo = true
        
        editData = data
    }
    
    func set(){
        placeImageView.image = receiveImage
        
        tfPlaceName.text = reName as String
        tfPlacePosition.text = rePositon
        tfCategory.text = reCategory
        swVisit.isOn = reVisit
        pkDate.date = reDate!
        txvComent.text = reComent
        lblRate.text = reRate
        
        rate.fill(buttons: rateButtons, rate: NSString(string: reRate).floatValue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let PlaceTableViewController = segue.destination as! PlaceTableViewController
        PlaceTableViewController.newImage = true
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
        return 9
    }

    @IBAction func btnAddDone(_ sender: UIButton){
        placeImages.updateValue(selectedImage, forKey: tfPlaceName.text!)
        
        tfPlaceName.placeholder = "이름을 입력하세요."
        tfPlacePosition.placeholder = "위치를 입력하세요."
        
        uploadData()
        uploadImage(tfPlaceName.text!, image: selectedImage)
        
        if delegate != nil{
            editData?.name = tfPlaceName.text
            editData?.position = tfPlacePosition.text
            editData?.category = tfCategory.text
            editData?.visit = swVisit.isOn
            editData?.date = pkDate.date
            editData?.coment = txvComent.text
            editData?.rate = lblRate.text

            delegate?.didEditPlace(self, data: editData!, image: selectedImage)
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func uploadData(){
        if reName != tfPlaceName.text! {
            db.collection("users").document(reName).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        let docData: [String: Any] = [
            "name": tfPlaceName.text!,
            "position": tfPlacePosition.text!,
            "date": pkDate.date,  //Timestamp(date: Date()),
            "visit": swVisit.isOn,
            "tag": ["태그1", "태그2", "태그3"],
            "rate": lblRate.text!,
            "coment": txvComent.text!,
            "category": tfCategory.text!
        ]

        db.collection("users").document(tfPlaceName.text!).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return PICKER_VIEW_COLUMN
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tfCategory.text = category[row]
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
        
    @IBAction func clickStar(_ sender: UIButton){
        lblRate.text = String(describing: rate.checkAttr(buttons: rateButtons, button: sender))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage //사진을 가져와 라이브러리에 저장

        placeImageView.image = selectedImage
        self.dismiss(animated: true, completion: nil)   //현재 뷰 컨트롤러 제거
    }
        
    //사용자가 사진이나 비디오를 찍지 않고 취소했을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)   //이미지 피커를 제거하고 초기 뷰를 보여줌
    }
        
    func uploadImage(_ path: String, image: UIImage){
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        let filePath = path
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.child(filePath).putData(data, metadata: metaData){
            (metaData, error) in if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("Image successfully upload!")
            }
        }
    }
    
    //경고 표시
    func myAlert(_ title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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
