//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import MapKit
import Firebase
import FirebaseFirestore
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, ImageDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
   
    let db: Firestore = Firestore.firestore()
    let optionPicker = UIPickerView()
    var locationManager: CLLocationManager!
    var mapView: GMSMapView?
    var points = [GeoPoint]()
    var places = [PlaceData]()
    var placeImages = [String : UIImage]()
    var placeTitle = ""
    var newUpdate = false
    var groupList = ["전체"]
    var categoryList = ["전체"]
    var optionedPlaces = [PlaceData]()

    @IBOutlet weak var optionTxtf: UITextField!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var typeSegment : UISegmentedControl!
    @IBOutlet weak var baseVeiw : UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        loadCategory()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // 앱이 실행될 때 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 위치 업데이트
        locationManager.startUpdatingLocation()
        let coor = locationManager.location?.coordinate
        
        let latitude = (coor?.latitude ?? 37.566508) as Double
        let longitude = (coor?.longitude ?? 126.977945) as Double
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        
        mapView?.delegate = self
        
        
  //      let camera = GMSCameraPosition.camera(withLatitude: 37.566508, longitude: 126.977945, zoom: 12.0)
  //      mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView!)
        self.view.bringSubviewToFront(optionTxtf)
        
        setOptionSearchPicker()
    }
    
    func setOptionSearchPicker(){
        let pickerToolbar = UIToolbar()
        let btnPickerDone = UIBarButtonItem()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        optionPicker.backgroundColor = UIColor.white
        optionPicker.frame = CGRect(x: 0, y: 0, width: 0, height: 200)
        pickerToolbar.frame = CGRect(x: 0, y: 0, width: 0, height: 40)
        pickerToolbar.barTintColor = UIColor.white
        optionTxtf.inputAccessoryView = pickerToolbar
        
        btnPickerDone.title = "검색"
        btnPickerDone.tintColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
        btnPickerDone.target = self
        btnPickerDone.action = #selector(pickerDone)
         
        pickerToolbar.setItems([flexSpace, btnPickerDone], animated: true)
         
        optionPicker.delegate = self
        optionTxtf.inputView = optionPicker
        optionPicker.reloadAllComponents()
    }
    
    @objc func pickerDone(){
        mapView?.clear()
        mark(optionedPlaces)
        self.view.endEditing(true)
    }
    
    func loadCategory(){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.groupList = self.groupList + (document.get("group") as? [String])!
                self.categoryList = self.categoryList + (document.get("items") as? [String])!
                self.optionPicker.reloadAllComponents()
                print("Document Success!")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func didImageDone(_ controller: PlaceInfoTableViewController, newData: PlaceData, image: UIImage) {
        placeImages.updateValue(image, forKey: newData.name)
        newUpdate = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if newUpdate == true{
            updateImg()
            newUpdate = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView?.clear()
        mark(places)
    }

    func updateImg(){
        let mainNav = self.tabBarController?.viewControllers![0] as! UINavigationController
        let mainCont = mainNav.topViewController as! MainPlaceViewController
        let calNav = self.tabBarController?.viewControllers![2] as! UINavigationController
        let calCont = calNav.topViewController as! CalendarController
        let searchNav = self.tabBarController?.viewControllers![1] as! UINavigationController
        let searchCont = searchNav.topViewController as! SearchTableViewController
            
        calCont.getDate(places, images: placeImages)
        searchCont.setData(places, images: placeImages)
        mainCont.updateImage(placeImages)
    }
    
    func mark(_ placeList: [PlaceData]){
        for place in placeList{
            self.makeMark(place.geopoint, placeTitle: place.name, placeAddress: place.location)
        }
    }
    
    func makeMark(_ point: GeoPoint, placeTitle: String, placeAddress: String){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        marker.title = placeTitle
        marker.snippet = placeAddress
        marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))
      //  marker.icon = UIImage(named: "example.jpeg")
        marker.map = mapView
    }
    
    
    func getPlace(_ data: [PlaceData], images: [String : UIImage]){
        places = data
        mark(places)
        placeImages = images
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        placeTitle = marker.title!
        self.performSegue(withIdentifier: "sgMapInfo", sender: self)
    }
    
   /*
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            print("markerTapped")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MapInfoController")
        vc.modalPresentationStyle = .popover
      //  let popover: UIPopoverPresentationController = vc.popoverPresentationController!
       // popover.barButtonItem = sender
        present(vc, animated: true, completion: nil)
            return true
        }
 */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return groupList.count
        }else{
            return categoryList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return groupList[row]
        }else{
            return categoryList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGroup = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = pickerView.selectedRow(inComponent: 1)
        
        if selectedGroup != 0 && selectedCategory != 0{
            optionedPlaces = places.filter{$0.group == groupList[selectedGroup] && $0.category == categoryList[selectedCategory]}
        }else if selectedGroup != 0{
            optionedPlaces = places.filter{$0.group == groupList[selectedGroup]}
        }else if selectedCategory != 0{
            optionedPlaces = places.filter{$0.category == categoryList[selectedCategory]}
        }else{
            optionedPlaces = places
        }
    }


    @IBAction func changeSegmentType(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            
        }else if sender.selectedSegmentIndex == 1{
            
        }else {
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "sgMapInfo"{
            let infoView = segue.destination as! PlaceInfoTableViewController
            let selectedPlace = places.first(where: {$0.name == placeTitle})
            
          //  infoView.getPlaceInfo(selectedPlace!, image: placeImages[(selectedPlace?.name)!]!)
            infoView.imgDelegate = self
            
            if  placeImages[(selectedPlace?.name)!] != nil{
                infoView.getPlaceInfo(selectedPlace!, image: placeImages[(selectedPlace?.name)!]!)
            }else{
                infoView.getPlaceInfo(selectedPlace!, image: UIImage(named: "wethere.jpeg")!)
                infoView.downloadImgInfo(selectedPlace!)
            }
        }
    }
}
/*
extension MapViewController : UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return groupList.count
        }else{
            return categoryList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return groupList[row]
        }else{
            return categoryList[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}*/
