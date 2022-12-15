//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06.
//


import UIKit
import FirebaseStorage
import FirebaseFirestore
import NVActivityIndicatorView

protocol ImageDelegate {
    func didImageDone(newData: PlaceData, image: UIImage)
}

class PlaceInfoTableViewController: UITableViewController, EditDelegate {
    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    
    var receiveImage: UIImage?
    
   // var hasimage = true
    var reName = "", rePositon = "", reDate = "", reCategory = "", reComent = "", reRate = "", reGroup = ""
    
    var rateButtons = [UIButton]()
    var editData : PlaceData?
    var imgDelegate : ImageDelegate?
    let loadingView = UIView()
    var isLoading = false
    
    
    @IBOutlet weak var placeImg: UIImageView!
    @IBOutlet weak var lblPlacename: UILabel!
    @IBOutlet weak var btnPosition: UIButton!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var txvComent: UITextView!
    @IBOutlet weak var btnRate1: UIButton!
    @IBOutlet weak var btnRate2: UIButton!
    @IBOutlet weak var btnRate3: UIButton!
    @IBOutlet weak var btnRate4: UIButton!
    @IBOutlet weak var btnRate5: UIButton!
  //  @IBOutlet weak var lblCount: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateButtons.append(btnRate1)
        rateButtons.append(btnRate2)
        rateButtons.append(btnRate3)
        rateButtons.append(btnRate4)
        rateButtons.append(btnRate5)
        
        setPlaceInfo()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        placeImg.isUserInteractionEnabled = true
        placeImg.addGestureRecognizer(tap)
                
        if isLoading{
            let width = placeImg.frame.midX
            let height = placeImg.frame.midY
            loadingView.frame = CGRect(x: 0, y: 0, width: placeImg.frame.width, height: placeImg.frame.height)
            loadingView.backgroundColor = UIColor.white
            self.view.addSubview(loadingView)
            let indicator = NVActivityIndicatorView(frame: CGRect(x: width - 25 , y: height - 25 , width: 50, height: 50),
                                                    type: .ballRotateChase,
                                                    color: .cyan,
                                                    padding: 0)
            loadingView.addSubview(indicator)
            indicator.startAnimating()
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // 메인 페이지에서 이미지가 다운되지 못했을 경우 정보 상세 페이지에서 이미지를 받아오는 함수
    func downloadImgInfo(_ place: PlaceData){
        let fileName = place.name
        let islandRef = storage.reference().child(Uid + "/" + fileName)
        isLoading = true
        islandRef.getData(maxSize: 1 * 1024 * 1024) { [self] data, error in
            let downloadImg = UIImage(data: data! as Data)
            if error == nil {
                getPlaceInfo(place, image: downloadImg!)
                setPlaceInfo()
                print("image download!!!" + fileName)
                if imgDelegate != nil{
                    imgDelegate?.didImageDone(newData: place, image: downloadImg!)
                }
                loadingView.removeFromSuperview()
            }else {
                print(error as Any)
            }
        }
    }
   
    func getPlaceInfo(_ data: PlaceData, image: UIImage){
        editData = data
        receiveImage = image
        reName = data.name
        rePositon = data.location
        reCategory = data.category
        reComent = data.coment
        reRate = data.rate
        reGroup = data.group
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        reDate = formatter.string(from: data.date)
    }
    
    func setPlaceInfo(){
        lblPlacename.text = reName
        lblCategory.text = reCategory
        txvComent.text = reComent
        lblRate.text = "  " + reRate + " 점"
        lblGroup.text = reGroup
        placeImg.image = receiveImage
        if rePositon != ""{
            let locationArray = rePositon.components(separatedBy: " ")
            var location: String = ""
            if locationArray.count >= 3{
                for i in 0...2{
                    location += locationArray[i]
                    location += " "
                }
                btnPosition.setTitle(" " + location + "  〉 ", for: .normal)
            }else{
                btnPosition.setTitle(" " + rePositon + "  〉 ", for: .normal)
            }
           // btnPosition.setTitleColor(.white, for: .normal)
            btnPosition.contentHorizontalAlignment = .left
        }
        let fillRate = AddRate()
        fillRate.fill(buttons: rateButtons, rate: NSString(string: reRate).floatValue)
        lblDate.text = reDate
    }
    
    func didEditPlace(_ controller: AddPlaceTableViewController, data: PlaceData, image: UIImage) {
         getPlaceInfo(data, image: image)
         setPlaceInfo()
        tableView.reloadData()
    }
    
    @IBAction func editBtn(_ sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let txtFavorit: String
        editData!.isFavorit ? (txtFavorit = "즐겨찾기 해제") : (txtFavorit = "즐겨찾기 추가")
        
        alert.addAction(UIAlertAction(title: "장소 편집", style: .default) { [self] _ in
            performSegue(withIdentifier: "editPlace", sender: self)
        })

        alert.addAction(UIAlertAction(title: "장소 삭제", style: .default) { [self] _ in
            _ = navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: editData)
        })
        
        alert.addAction(UIAlertAction(title: txtFavorit, style: .default){ [self] _ in
            let placeRef = db.collection(Uid).document(reName)
            let isFavorit = editData!.isFavorit
            editData?.isFavorit = !isFavorit
            placeRef.updateData([ "favorit": !isFavorit ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            let alert = UIAlertController(title: txtFavorit, message: "즐겨찾기가 변경되었습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        })
                        
        alert.addAction(UIAlertAction(title: "취소", style: .destructive))
        present(alert, animated: true)
    }
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "sgShowImage", sender: self)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && editData?.image == false{
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "editPlace":
            let addPlaceViewController = segue.destination as! AddPlaceTableViewController
            addPlaceViewController.setPlaceDataFromInfo(data: editData!, image: receiveImage!)
            addPlaceViewController.editDelegate = self
        case "sgShowImage":
            let imageView = segue.destination as! ImageViewController
            imageView.fullImage = placeImg.image
        case "showMap":
            let addressController = segue.destination  as! MapViewController
            addressController.onePlace = editData!
        default:
            print("잘못된 segue")
        }
    }
}

