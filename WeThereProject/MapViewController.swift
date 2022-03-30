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

class MapViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, ImageDelegate{
   
    let db: Firestore = Firestore.firestore()
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
    var onePlace : PlaceData?
    
    @IBOutlet var viewMap: UIView!
    
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
        
        viewMap.addSubview(mapView!)
        
        mark(places)
        
        if onePlace != nil{
            showAddressMarker(placeData: onePlace!)
        }
    }
    
    func loadCategory(){
        let docRef = db.collection("category").document(Uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.groupList = self.groupList + (document.get("group") as? [String])!
                self.categoryList = self.categoryList + (document.get("items") as? [String])!
                print("Document Success!")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func showAddressMarker(placeData : PlaceData){
        let oneList = [placeData]
        let camera = GMSCameraPosition.camera(
            withLatitude: (placeData.geopoint.latitude) as Double,
            longitude: (placeData.geopoint.longitude) as Double,
            zoom: 15
          )
        mapView?.clear()
        mapView?.camera = camera
        mark(oneList)
    }
    
    func didImageDone(newData: PlaceData, image: UIImage) {
        placeImages.updateValue(image, forKey: newData.name)
        newUpdate = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if newUpdate == true{
            updateImg()
            newUpdate = false
        }
    }

    /*override func viewWillAppear(_ animated: Bool) {
        if onePlace == nil{
            mark(places)
        }
    }*/

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
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: place.geopoint.latitude, longitude: place.geopoint.longitude)
            marker.title = place.name
            marker.snippet = place.location
         //   marker.icon = GMSMarker.markerImage(with: #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)) 색깔로만
            if place.isFavorit {
                marker.icon = UIImage(named: "marker_basic")
                marker.userData = 0
            }else{
                marker.icon = UIImage(named: "marker_novisit")
                marker.userData = 1
            }
            marker.setIconSize(scaledToSize: .init(width: 30, height: 40))
            marker.map = mapView
            if onePlace != nil {
                mapView?.selectedMarker = marker
            }
        }
    }
    
    func getPlace(_ data: [PlaceData], images: [String : UIImage]){
        places = data
        mark(places)
        placeImages = images
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if onePlace == nil{
            placeTitle = marker.title!
            self.performSegue(withIdentifier: "sgMapInfo", sender: self)
        }else{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if marker.userData as! Int == 0{
            marker.icon = UIImage(named: "marker_basic")
        }else{
            marker.icon = UIImage(named: "marker_novisit")
        }

        marker.setIconSize(scaledToSize: .init(width: 30, height: 40))
    }
    
   
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        marker.icon = UIImage(named: "marker_select")
        marker.setIconSize(scaledToSize: .init(width: 30, height: 40))
        return false
    }
    
 
    
    @IBAction func addFilter(_ sender: UIButton){
        if onePlace == nil{
            let optionPicker = UIPickerView(frame: CGRect(x: 10, y: 50, width: 250, height: 150))
            optionPicker.delegate = self
            optionPicker.dataSource = self
            optionPicker.reloadAllComponents()
            
            let filterAlert = UIAlertController(title: "조건 선택", message: "\n\n\n\n\n\n\n\n", preferredStyle: .alert)
            filterAlert.view.addSubview(optionPicker)
            
            pickerView(optionPicker, didSelectRow: 0, inComponent:0)
            
            filterAlert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            filterAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: { UIAlertAction in
                self.mapView?.clear()
                self.mark(self.optionedPlaces)
            }))
            
            self.present(filterAlert, animated: true, completion: nil)
        }else{
            let onePlaceAlert = UIAlertController(title: "조건 검색 불가", message: "\n 현재 지도에선 상세 검색을 할 수 없습니다.", preferredStyle: .alert)
            onePlaceAlert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self.present(onePlaceAlert, animated: true, completion: nil)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgMapInfo"{
            let infoView = segue.destination as! PlaceInfoTableViewController
            let selectedPlace = places.first(where: {$0.name == placeTitle})

            infoView.imgDelegate = self
            infoView.modalPresentationStyle = .fullScreen
            
            if let placeImage = placeImages[(selectedPlace?.name)!]{
                infoView.getPlaceInfo(selectedPlace!, image: placeImage)
            }else{
                if selectedPlace!.image{
                    infoView.downloadImgInfo(selectedPlace!)
                }else{
                    //infoView.hasimage = false
                    infoView.getPlaceInfo(selectedPlace!, image: UIImage(named: "pdicon")!)
                }
            }
        }
    }
}

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
}

extension GMSMarker {
    func setIconSize(scaledToSize newSize: CGSize) {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        icon?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        icon = newImage
    }
}
