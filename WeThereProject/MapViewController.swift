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

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!

    var mapView: GMSMapView?
    var points = [GeoPoint]()
    
    var places = [PlaceData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 구글 지도 표시하기
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate 37.566508,126.977945 at zoom level 16.
        let camera = GMSCameraPosition.camera(withLatitude: 37.566508, longitude: 126.977945, zoom: 12.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView!)

        // Creates a marker in the center of the map.
       
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        // 앱이 실행될 때 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        // 배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 위치 업데이트
        locationManager.startUpdatingLocation()
        
        // 위, 경도 가져오기
        /*
        let coor = locationManager.location?.coordinate
        
        let latitude = (coor?.latitude ?? 37.566508) as Double
        let longitude = (coor?.longitude ?? 126.977945) as Double
        camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        */

        let gm = GeoPoint(latitude: 37.566508, longitude: 126.977945)
        makeMark(gm, placeTitle: "표시", placeAddress: "양천구")
        mark()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    func mark(){
      //  print(places[0].name!)
        for place in places{
            print("돼용")
            self.makeMark(place.geopoint!, placeTitle: place.name!, placeAddress: place.position!)
        }
    }
    
    func makeMark(_ point: GeoPoint, placeTitle: String, placeAddress: String){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        marker.title = placeTitle
        marker.snippet = placeAddress
        marker.map = mapView
    }
    
    func getPlace(_ data: [PlaceData]){
    
        places = data
        
        print(places[0].name!)
        for place in places{
            print("돼용")
            makeMark(place.geopoint!, placeTitle: place.name!, placeAddress: place.position!)
        }
        
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

