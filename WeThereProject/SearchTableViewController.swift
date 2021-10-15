//
//  SearchTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/23.
//

import UIKit

class SearchTableViewController: UITableViewController, ImageDelegate {

    @IBOutlet var searchTableView: UITableView!
    
    var newUpdate = false
    var places = [PlaceData]()
    var placeImages = [String : UIImage]()
    var filterArray = [PlaceData]()
    var txtSearch : String?
    var placeName = [String](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setSearchController()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func setSearchController(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "키워드 검색 ex. 이름, 내용..."
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchResultsUpdater = self
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
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
    
    func updateImg(){
        let mainNav = self.tabBarController?.viewControllers![0] as! UINavigationController
        let mainCont = mainNav.topViewController as! MainPlaceViewController
        let calNav = self.tabBarController?.viewControllers![2] as! UINavigationController
        let calCont = calNav.topViewController as! CalendarController
        let mapNav = self.tabBarController?.viewControllers![3] as! UINavigationController
        let mapCont = mapNav.topViewController as! MapViewController
            
        calCont.getDate(places, images: placeImages)
        mapCont.getPlace(places, images: placeImages)
        mainCont.updateImage(placeImages)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            if filterArray.count == 0{
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                emptyLabel.text = "검색된 장소가 없습니다."
                emptyLabel.textAlignment = NSTextAlignment.center
                tableView.backgroundView = emptyLabel
                tableView.separatorStyle = .none
                return 0
            }else{
                tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                tableView.backgroundView = .none
                return filterArray.count
            }
        }else{
            if placeName.count == 0{
                let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                emptyLabel.text = "검색할 장소가 없습니다."
                emptyLabel.textAlignment = NSTextAlignment.center
                tableView.backgroundView = emptyLabel
                tableView.separatorStyle = .none
                return 0
            }else{
                tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
                tableView.backgroundView = .none
                return placeName.count
            }
        }
        
        
        
       // return isSearching ? filterArray.count : self.placeName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchResultCell

        if self.isSearching{
            let name = NSMutableAttributedString(string: filterArray[(indexPath as NSIndexPath).row].name)
            name.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1), range: (filterArray[(indexPath as NSIndexPath).row].name as NSString).range(of: self.txtSearch!))
            let address = NSMutableAttributedString(string: filterArray[(indexPath as NSIndexPath).row].location)
            address.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1), range: (filterArray[(indexPath as NSIndexPath).row].location as NSString).range(of: self.txtSearch!))
            
            cell.lblName.attributedText = name
            cell.lblLocation.attributedText = address

        }else{
            cell.lblName.text = places[(indexPath as NSIndexPath).row].name
            cell.lblLocation.text = places[(indexPath as NSIndexPath).row].location
        }
        return cell
    }
    

    func setData(_ data: [PlaceData], images: [String : UIImage]){
        places = data
        placeName.removeAll()
        for place in data{
            placeName.append(place.name)
        }
        placeImages = images
    }
    
    var isSearching: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
  

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgSearchInfo"{
            let cell = sender as! UITableViewCell
            let indexPath = self.searchTableView.indexPath(for: cell)
            let infoView = segue.destination as! PlaceInfoTableViewController
            var selectedPlace: PlaceData!
            
            infoView.imgDelegate = self
            
            if isSearching{
                selectedPlace = places.first(where: {$0.name == filterArray[(indexPath! as NSIndexPath).row].name})
            }else{
                selectedPlace = places.first(where: {$0.name == places[(indexPath! as NSIndexPath).row].name})
            }
            
            if let placeImage = placeImages[(selectedPlace.name)]{
                infoView.getPlaceInfo(selectedPlace, image: placeImage)
            }else{
                if selectedPlace.image{
                    infoView.downloadImgInfo(selectedPlace)
                }else{
                    infoView.hasimage = false
                    infoView.getPlaceInfo(selectedPlace, image: UIImage(named: "pdicon")!)
                }
            }
          
        }
    }
    

}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        self.txtSearch = searchText
        self.filterArray =  self.places.filter {$0.name.localizedCaseInsensitiveContains(searchText) || $0.location.localizedCaseInsensitiveContains(searchText) || $0.coment.localizedCaseInsensitiveContains(searchText)}
          
        self.tableView.reloadData()
    }
}
