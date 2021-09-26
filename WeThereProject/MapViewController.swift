//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import MapKit
import Firebase
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ImageDelegate {
   
    var locationManager: CLLocationManager!
    var mapView: GMSMapView?
    var points = [GeoPoint]()
    var places = [PlaceData]()
    var placeImages = [String : UIImage]()
    var placeTitle = ""
    var newUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
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

        // Creates a marker in the center of the map.
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
        mark()
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
    
    func mark(){
        for place in places{
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
        mark()
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

