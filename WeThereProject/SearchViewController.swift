//
//  SearchViewController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    
    var placeName = ["가나다", "꼼마", "사랑", "블랑제메종", "망원공원"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setSearchController()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
          
    func setData(_ data: [PlaceData]){
        for place in data{
            placeName.append(place.name!)
        }
    }
    
    func setSearchController(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "키워드 검색 ex. 이름, 내용..."
        searchController.hidesNavigationBarDuringPresentation = false
        
        self.navigationItem.searchController = searchController
        self.navigationItem.title = "검색"
        self.navigationItem.hidesSearchBarWhenScrolling = false
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


extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.placeName.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeName[(indexPath as NSIndexPath).row]
        return cell
    }
}

