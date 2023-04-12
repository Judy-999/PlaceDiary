//
//  MapViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import RxSwift
import GoogleMaps
import GooglePlaces

final class MapViewController: UIViewController {
    private let locationManager = CLLocationManager()
    private var mapView: GMSMapView?
    private var classification = Classification()
    private var optionedPlaces = [Place]()
    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()
    var onePlace: Place?
    
    @IBOutlet private weak var entireView: UIView!
    @IBOutlet private weak var filterButton: UIBarButtonItem!
    
    required init?(viewModel: MapViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadClassification()
        setupLocationManager()
        setupMapView()
        viewModel.loadPlaceData(disposeBag)
        bind()
        filterButton.isEnabled = onePlace == nil
        
        if let place = onePlace {
            selectMarker(at: place)
        }
    }
    
    private func bind() {
        viewModel.places
            .subscribe(onNext: { [weak self] places in
                self?.drawMarkers(with: places)
            })
            .disposed(by: disposeBag)
        
        viewModel.classification
            .subscribe(onNext: { [weak self] classification in
                self?.classification = Classification(category: [PlaceInfo.Map.allType] + classification.group,
                                                      group: [PlaceInfo.Map.allType] + classification.category)
            })
            .disposed(by: disposeBag)
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
        
        entireView.addSubview(mapView!)
    }
    
    private func loadClassification() {
        //TODO: load Classification
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
        filterAlert.addAction(Alert.cancel)
        filterAlert.addAction(UIAlertAction(title: "확인", style: .default,
                                            handler: { [self] _ in drawMarkers(with: optionedPlaces) }))
        
        present(filterAlert, animated: true, completion: nil)
    }
    
    private func showDetailView(with name: String) {
        let places = viewModel.places.value
        guard let selectedPlace = places.first(where: { $0.name == name }) else { return }

        viewModel.showPlaceDetail(selectedPlace)
    }
}

// MARK: GMSMapView
extension MapViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if onePlace == nil {
            let selectedPlaceName = marker.title ?? ""
            showDetailView(with: selectedPlaceName)
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

// MARK: PickerView
extension MapViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return classification.group.count
        }
        
        return classification.category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return classification.group[row]
        }
        
        return classification.category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGroup = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = pickerView.selectedRow(inComponent: 1)
        var filterdPlaces = viewModel.places.value
        
        if selectedGroup != 0 {
            filterdPlaces = filterdPlaces.filter { $0.group == classification.group[selectedGroup] }
        }
        
        if selectedCategory != 0 {
            filterdPlaces = filterdPlaces.filter { $0.category == classification.category[selectedCategory] }
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
