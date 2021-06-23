//
//  SearchTableViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/23.
//

import UIKit

class SearchTableViewController: UITableViewController {

    @IBOutlet var searchTableView: UITableView!
    
    var places = [PlaceData]()
    var placeName = [String](){
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //["가나다", "꼼마", "사랑", "블랑제메종", "망원공원"]
    var filterArray : [String] = []
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

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return isSearching ? filterArray.count : self.placeName.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)

        if self.isSearching{
            cell.textLabel?.text = filterArray[(indexPath as NSIndexPath).row]
        }else{
            cell.textLabel?.text = placeName[(indexPath as NSIndexPath).row]
        }
        return cell
    }
    

    func setData(_ data: [PlaceData]){
        places = data
        placeName.removeAll()
        for place in data{
            placeName.append(place.name!)
        }
    }
    
    var isSearching: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        return isActive && isSearchBarHasText
    }
  
   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgSearchInfo"{
            let cell = sender as! UITableViewCell
            let indexPath = self.searchTableView.indexPath(for: cell)
            let infoView = segue.destination as! PlaceInfoTableViewController
            
            /*
            var i: PlaceData!
            
            if isSearching{
                i = places.first(where: {$0.name == filterArray[(indexPath! as NSIndexPath).row]})
            }else{
                i = places.first(where: {$0.name == placeName[(indexPath! as NSIndexPath).row]})
            }
            
            infoView.getInfo(i, image: placeImages[i.name!]!)
            */
            infoView.getInfo(places[(indexPath! as NSIndexPath).row], image: placeImages[places[(indexPath! as NSIndexPath).row].name!]!)
        }
    }
    

}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        self.filterArray = self.placeName.filter {$0.localizedCaseInsensitiveContains(searchText)}
        self.tableView.reloadData()
    }
}
