//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 구글 지도 표시하기
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate 37.566508,126.977945 at zoom level 16.
        var camera = GMSCameraPosition.camera(withLatitude: 37.566508, longitude: 126.977945, zoom: 16.0)
        var mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)

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
        let coor = locationManager.location?.coordinate
        
        let latitude = (coor?.latitude ?? 37.566508) as Double
        let longitude = (coor?.longitude ?? 126.977945) as Double

        camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.title = "현재 위치"
        marker.snippet = "서울시 양천구"
        marker.map = mapView
        // 현재 위치 가져오기
       
    }
}
    
/*    UIViewController {

    var locationManager: CLLocationManager!
      var currentLocation: CLLocation?
      var mapView: GMSMapView!
      var placesClient: GMSPlacesClient!
      var preciseLocationZoomLevel: Float = 15.0
      var approximateLocationZoomLevel: Float = 10.0

      // An array to hold the list of likely places.
      var likelyPlaces: [GMSPlace] = []

      // The currently selected place.
      var selectedPlace: GMSPlace?

      // Update the map once the user has made their selection.
      @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        // Clear the map.
        mapView.clear()

        // Add a marker to the map.
        if let place = selectedPlace {
          let marker = GMSMarker(position: place.coordinate)
          marker.title = selectedPlace?.name
          marker.snippet = selectedPlace?.formattedAddress
          marker.map = mapView
        }

        listLikelyPlaces()
      }

      override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        placesClient = GMSPlacesClient.shared()

        // A default location to use when location permission is not granted.
        let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
        
        // Create a map.
        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true

        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true

        listLikelyPlaces()
      }

      // Populate the array with the list of likely places.
      func listLikelyPlaces() {
        // Clean up from previous sessions.
        likelyPlaces.removeAll()

        let placeFields: GMSPlaceField = [.name, .coordinate]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { (placeLikelihoods, error) in
          guard error == nil else {
            // TODO: Handle the error.
            print("Current Place error: \(error!.localizedDescription)")
            return
          }

          guard let placeLikelihoods = placeLikelihoods else {
            print("No places found.")
            return
          }
          
          // Get likely places and add to the list.
          for likelihood in placeLikelihoods {
            let place = likelihood.place
            self.likelyPlaces.append(place)
          }
        }
      }

      // Prepare the segue.
      override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToSelect" {
          if let nextViewController = segue.destination as? PlaceViewController {
            nextViewController.likelyPlaces = likelyPlaces
          }
        }
      }
    }

    // Delegates to handle events for the location manager.
    extension MapViewController: CLLocationManagerDelegate {

      // Handle incoming location events.
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")

        let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : approximateLocationZoomLevel
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)

        if mapView.isHidden {
          mapView.isHidden = false
          mapView.camera = camera
        } else {
          mapView.animate(to: camera)
        }

        listLikelyPlaces()
      }

      // Handle authorization for the location manager.
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
          fatalError()
        }
        
        // Handle authorization status
        switch status {
        case .restricted:
          print("Location access was restricted.")
        case .denied:
          print("User denied access to location.")
          // Display the map using the default location.
          mapView.isHidden = false
        case .notDetermined:
          print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
          print("Location status is OK.")
        @unknown default:
          fatalError()
        }
      }

      // Handle location manager errors.
      func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
      }
    
        */
        
        
    /*
    //위도, 경도로 지도에 표시
    func goLocation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span: Double) -> CLLocationCoordinate2D{
        let pLocation = CLLocationCoordinate2DMake(latitudeValue, longitudeValue)   //위도, 경도 값을 2D로?
        let spanValue = MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span) //보이는 범위?
        let pRegion = MKCoordinateRegion(center: pLocation, span: spanValue)
        mapView.setRegion(pRegion, animated: true)
        return pLocation
    }
    
    //특정 위도, 경도에 핀 설치하고 타이틀과 서브 타이틀 표시
    func setAnnotation(latitudeValue: CLLocationDegrees, longitudeValue: CLLocationDegrees, delta span :Double, title strTitle: String, subtitle subTitle:String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = goLocation(latitudeValue: latitudeValue, longitudeValue: longitudeValue, delta: span)
        annotation.title = strTitle
        annotation.subtitle = subTitle
        mapView.addAnnotation(annotation)
    }
    
    //위치 정보에서 국가, 지역, 도로를 추출하여 레이블에 표시
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let pLocation = locations.last  //위치가 업데이트 되면 마지막 위치값을 찾음
        
        _=goLocation(latitudeValue: (pLocation?.coordinate.latitude)!, longitudeValue: (pLocation?.coordinate.longitude)!, delta: 0.01)   //마지막 위치로 지도에 표시(delta 값은 지도의 크기 ex) 0.01 -> 100배로 확대)
        
        //위도, 경도로 역으로 주소 찾기
        CLGeocoder().reverseGeocodeLocation(pLocation!, completionHandler: {
            (placemarks, error) -> Void in
            let pm = placemarks!.first  //placemarks 값의 첫 부분을 pm에 넣기
            let country = pm!.country   //pm에서 나라 값을 country에 넣기
            var address: String = country!
            if pm!.locality != nil{//지역 값이 존재하면 address에 추가
                address += " "
                address += pm!.locality!
            }
            if pm!.thoroughfare != nil{//도로 값이 존재하면 address에 추가
                address += " "
                address += pm!.thoroughfare!
            }
        })
        
        locationManager.stopUpdatingLocation()  //위치 업데이트 중지
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

//}

