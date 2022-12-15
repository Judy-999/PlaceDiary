//
//  CalendarController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/29. --> Refacted on 2022/12/15
//

import UIKit
import FSCalendar

struct PlaceDate{
    var date: Date
    var name: [String]
}

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, ImageDelegate {

    var newUpdate = false
    var placeDay = [Date]()
    var places = [Place]()
    var placeImages = [String : UIImage]()
    var selectedDate = ""
    var nameDate = [Date : String]()
    var selectedName = [String]()
    var dates = [PlaceDate]()
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalendar()
        calendar.reloadData()
    }

    func getDate(_ data: [Place], images: [String : UIImage]){
        dates.removeAll()
        places = data
        for place in places{
            let placeDay = transDate(place.date)
            let placeName = place.name
            var sameDay = dates.first(where: {$0.date == placeDay})
            if sameDay == nil{
                let placeDate: PlaceDate = PlaceDate(date: placeDay, name: [placeName])
                dates.append(placeDate)
            }else{
                let index = dates.firstIndex(where: {$0.date == placeDay})!
                dates.remove(at: index)
                sameDay?.name.append(placeName)
                dates.append(sameDay!)
            }
        }
        placeImages = images
    }

    
    func setCalendar(){
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.weekdayTextColor = UIColor.black
        calendar.appearance.headerTitleColor = UIColor.black
        calendar.appearance.selectionColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
        calendar.appearance.todayColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        calendar.appearance.todaySelectionColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
        calendar.appearance.titleWeekendColor = UIColor.blue
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.eventDefaultColor = #colorLiteral(red: 0, green: 0.8924261928, blue: 0.8863361478, alpha: 1)
        calendar.appearance.eventSelectionColor = .red
        calendar.backgroundColor = UIColor.white
        calendar.locale = Locale(identifier: "ko_KR")
    }
    
    func transDate(_ day: Date) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateString = formatter.string(from: day)
        let date = formatter.date(from: dateString)

        return date!
    }

    func didImageDone(newData: Place, image: UIImage) {
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
        let searchNav = self.tabBarController?.viewControllers![1] as! UINavigationController
        let searchCont = searchNav.topViewController as! SearchTableViewController
        let mapNav = self.tabBarController?.viewControllers![3] as! UINavigationController
        let mapCont = mapNav.topViewController as! MapViewController
            
        searchCont.setData(places, images: placeImages)
        mapCont.getPlace(places, images: placeImages)
        mainCont.updateImage(placeImages)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let eventDay = dates.first(where: {$0.date == date})
        if eventDay == nil{
            return 0
        }else if (eventDay?.name.count)! < 3{
            return (eventDay?.name.count)!
        }else{
            return 3
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if let eventDay = dates.first(where: {$0.date == date}){
            selectedName = eventDay.name
            tableView.reloadData()
        }else{
            selectedName.removeAll()
            tableView.reloadData()
        }
    }
}

extension CalendarController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedName.count == 0{
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "장소가 없습니다."
            emptyLabel.textAlignment = NSTextAlignment.center
            tableView.backgroundView = emptyLabel
            tableView.separatorStyle = .none
            return 0
        }else{
            tableView.backgroundView = .none
            return selectedName.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calCell", for: indexPath)
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        cell.textLabel?.text = selectedName[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sgCalendarInfo"{
            let cell = sender as! UITableViewCell
            let indexPath = self.tableView.indexPath(for: cell)
            let infoView = segue.destination as! PlaceInfoTableViewController
            
            let selectedPlace = places.first(where: {$0.name == selectedName[(indexPath! as NSIndexPath).row]})
            
            infoView.imgDelegate = self
            
            if let placeImage = placeImages[(selectedPlace?.name)!]{
                infoView.getPlaceInfo(selectedPlace!, image: placeImage)
            }else{
                if selectedPlace!.hasImage{
                    infoView.downloadImgInfo(selectedPlace!)
                }else{
                    infoView.getPlaceInfo(selectedPlace!, image: UIImage(named: "pdicon")!)
                }
            }
        }
    }
}
