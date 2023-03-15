//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, ImageDelegate {
    private let locationManager = CLLocationManager()
    private var mapView: GMSMapView?
    private var places = [Place]()
    private var selectedPlaceName = String()
    private var groupList = [PlaceInfo.Map.allType]
    private var categoryList = [PlaceInfo.Map.allType]
    private var optionedPlaces = [Place]()
    var onePlace: Place?
    
    @IBOutlet private weak var filterButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        setupLocationManager()
        setupMapView()
        drawMarkers(with: places)
        filterButton.isEnabled = onePlace == nil
        
        if let place = onePlace {
            selectMarker(at: place)
        }
    }
    
    func didImageDone(newData: Place, image: UIImage) {
        //        placeImages.updateValue(image, forKey: newData.name)
        //        newUpdate = true
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func setupMapView() {
        let coor = locationManager.location?.coordinate
        let latitude = (coor?.latitude ?? 37.566508) as Double
        let longitude = (coor?.longitude ?? 126.977945) as Double
        let camera = GMSCameraPosition.camera(withLatitude: latitude,
                                              longitude: longitude,
                                              zoom: 12)
        
        mapView = GMSMapView.map(withFrame: view.frame, camera: camera)
        mapView?.settings.myLocationButton = true
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        
        view.addSubview(mapView!)
    }
    
    private func loadCategory() {
        FirestoreManager.shared.loadClassification { [weak self] categoryItems, groupItems in
            self?.groupList += groupItems
            self?.categoryList += categoryItems
        }
    }
    
    private func selectMarker(at place: Place) {
        let oneList = [place]
        let camera = GMSCameraPosition.camera(withLatitude: place.geopoint.latitude,
                                              longitude: place.geopoint.longitude,
                                              zoom: 15)
        mapView?.clear()
        mapView?.camera = camera
        drawMarkers(with: oneList)
    }
    
    private func drawMarkers(with placeList: [Place]) {
        mapView?.clear()
        
        for place in placeList {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: place.geopoint.latitude,
                                                     longitude: place.geopoint.longitude)
            
            let markerImage = place.isFavorit ? DiaryImage.Marker.favorit : DiaryImage.Marker.notFavorit
            
            marker.icon = markerImage
            marker.userData = markerImage
            marker.setIconSize(scaledToSize: PlaceInfo.Map.makerSize)
            marker.map = mapView
            marker.title = place.name
            marker.snippet = place.location
            
            if onePlace != nil {
                mapView?.selectedMarker = marker
            }
        }
    }
    
    func getPlace(_ data: [Place], images: [String : UIImage]) {
        places = data
        drawMarkers(with: places)
        //        placeImages = images
    }
    
    @IBAction func filterButtonTapped(_ sender: UIButton) {
        sender.isHidden = onePlace == nil ? false : true
        
        let optionPicker = UIPickerView(frame: CGRect(x: 10,
                                                      y: 30,
                                                      width: 250,
                                                      height: 100))
        optionPicker.delegate = self
        optionPicker.dataSource = self
        optionPicker.reloadAllComponents()
        pickerView(optionPicker, didSelectRow: 0, inComponent: 0)
        
        let filterAlert = UIAlertController(title: "조건 선택",
                                            message: "\n\n\n\n",
                                            preferredStyle: .alert)
        
        filterAlert.view.addSubview(optionPicker)
        filterAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        filterAlert.addAction(UIAlertAction(title: "확인", style: .default,
                                            handler: { [self] _ in drawMarkers(with: optionedPlaces) }))
        
        present(filterAlert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.mapInfo.identifier {
            guard let infoView = segue.destination as? PlaceInfoTableViewController,
                  let selectedPlace = places.first(where: { $0.name == selectedPlaceName }) else { return }
            
            infoView.imgDelegate = self
            infoView.modalPresentationStyle = .fullScreen
            infoView.getPlaceInfo(selectedPlace)
        }
    }
}

extension MapViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if onePlace == nil {
            selectedPlaceName = marker.title ?? ""
            self.performSegue(withIdentifier: Segue.mapInfo.identifier, sender: self)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        marker.icon = marker.userData as? UIImage
        marker.setIconSize(scaledToSize: PlaceInfo.Map.makerSize)
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        marker.icon = DiaryImage.Marker.select
        marker.setIconSize(scaledToSize: PlaceInfo.Map.makerSize)
        return false
    }
}

extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return groupList.count
        }
        
        return categoryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return groupList[row]
        }
        
        return categoryList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGroup = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = pickerView.selectedRow(inComponent: 1)
        var filterdPlaces = places
        
        if selectedGroup != 0 {
            filterdPlaces = filterdPlaces.filter { $0.group == groupList[selectedGroup] }
        }
        
        if selectedCategory != 0 {
            filterdPlaces = filterdPlaces.filter { $0.category == categoryList[selectedCategory] }
        }
        
        optionedPlaces = filterdPlaces
    }
}

extension GMSMarker {
    func setIconSize(scaledToSize size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, .zero)
        icon?.draw(in: CGRect(x: .zero,
                              y: .zero,
                              width: size.width,
                              height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        icon = resizedImage
    }
}
