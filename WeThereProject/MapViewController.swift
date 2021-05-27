//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest   //정확도를 최고로 설정
        locationManager.requestWhenInUseAuthorization() //위치 정보 승인 요청
        locationManager.startUpdatingLocation() // 위치 업데이트
        mapView.showsUserLocation = true
    }
    
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

}
