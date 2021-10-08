//
//  PlaceInfoTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/06.
//


import UIKit
import Firebase
import NVActivityIndicatorView

protocol ImageDelegate {
    func didImageDone(newData: PlaceData, image: UIImage)
}

class PlaceInfoTableViewController: UITableViewController, EditDelegate {
    
    let storage = Storage.storage()
    let db: Firestore = Firestore.firestore()
    let fillRate = AddRate()
    var receiveImage: UIImage?
    var reName = "", rePositon = "", reDate = "", reCategory = "", reComent = "", reRate = "", reGroup = "", count = "0"
    var reVisit = false
    var rateBtn = [UIButton]()
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
    @IBOutlet weak var lblCount: UILabel!
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
     
        rateBtn.append(btnRate1)
        rateBtn.append(btnRate2)
        rateBtn.append(btnRate3)
        rateBtn.append(btnRate4)
        rateBtn.append(btnRate5)
        
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
    }
    
    func getPlaceInfo(_ data: PlaceData, image: UIImage){
        editData = data
        
        reName = data.name
        rePositon = data.location
        receiveImage = image
        reCategory = data.category
        reVisit = data.visit
        reRate = data.rate
        reComent = data.coment
        count = data.count
        reGroup = data.group
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        reDate = formatter.string(from: data.date)
    }
    
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
    
    func setPlaceInfo(){
        lblPlacename.text = reName
        btnPosition.setTitle(" " + rePositon + "  >", for: .normal)
        btnPosition.setTitleColor(.white, for: .normal)
        btnPosition.contentHorizontalAlignment = .left
        lblDate.text = reDate
        lblCategory.text = reCategory
        txvComent.text = reComent
        lblRate.text = "  " + reRate + " 점"
        lblCount.text = count + "회"
        lblGroup.text = reGroup
        placeImg.image = receiveImage
        fillRate.fill(buttons: rateBtn, rate: NSString(string: reRate).floatValue)
    }
    
    func didEditPlace(_ controller: AddPlaceTableViewController, data: PlaceData, image: UIImage) {
         getPlaceInfo(data, image: image)
         setPlaceInfo()
    }
    
    @IBAction func editBtn(_ sender: UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "장소 편집", style: .default) { _ in
            self.performSegue(withIdentifier: "editPlace", sender: self)
        })

        alert.addAction(UIAlertAction(title: "장소 삭제", style: .default) { _ in
            _ = self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newPlaceUpdate"), object: self.editData)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPlace"{
            let addPlaceViewController = segue.destination as! AddPlaceTableViewController
            addPlaceViewController.setPlaceDataFromInfo(data: editData!, image: receiveImage!)
            addPlaceViewController.editDelegate = self
        }
        if segue.identifier == "sgShowImage"{
            let imageView = segue.destination as! ImageViewController
            imageView.fullImage = placeImg.image
        }
        if segue.identifier == "showMap"{
            let addressController = segue.destination  as! MapViewController
            addressController.onePlace = editData!
        }
    }
}


