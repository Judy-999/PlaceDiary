//
//  CalendarController.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/06/29. --> Refacted on 2022/12/15
//

import UIKit
import RxSwift
import FSCalendar

final class CalendarController: UIViewController {
    private let viewModel: MainViewModel
    private let disposeBag = DisposeBag()
    private var eventPlaces = [Place]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet private weak var calendar: FSCalendar!
    @IBOutlet private weak var tableView: UITableView!
    
    required init?(viewModel: MainViewModel, coder: NSCoder) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        calendar.reloadData()
    }
    
    private func setupCalendar() {
        calendar.appearance.headerDateFormat = PlaceInfo.Calendar.headerFormat
        calendar.appearance.todayColor = Color.partialHighlight
        calendar.appearance.todaySelectionColor = Color.highlight
        calendar.appearance.selectionColor = Color.highlight
        calendar.appearance.eventDefaultColor = Color.highlight
        calendar.appearance.weekdayTextColor = .label
        calendar.appearance.headerTitleColor = .label
        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.titleWeekendColor = .systemBlue
        calendar.appearance.eventSelectionColor = .systemRed
        calendar.backgroundColor = .systemBackground
    }
}

// MARK: FSCalendar
extension CalendarController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let places = viewModel.places.value
        let eventDay = places.filter { $0.date.toRegular == date }
        return eventDay.count > PlaceInfo.Calendar.eventCount ?
        PlaceInfo.Calendar.eventCount : eventDay.count
    }
    
    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        let places = viewModel.places.value
        eventPlaces = places.filter { $0.date.toRegular == date }
    }
}

// MARK: - TableViewDataSource & TableViewDelegate
extension CalendarController: UITableViewDelegate, UITableViewDataSource {
    private func initializeTableView(with coment: String) {
        let emptyLabel = UILabel(frame: CGRect(x: .zero,
                                               y: .zero,
                                               width: view.bounds.size.width,
                                               height: view.bounds.size.height))
        emptyLabel.text = coment
        emptyLabel.textAlignment = NSTextAlignment.center
        tableView.backgroundView = emptyLabel
        tableView.separatorStyle = .none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = .none
        tableView.separatorStyle = .singleLine
        
        if eventPlaces.isEmpty {
            initializeTableView(with: PlaceInfo.Calendar.emptyDate)
        }
        
        return eventPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calCell", for: indexPath)
        cell.textLabel?.font = .preferredFont(forTextStyle: .title3)
        cell.textLabel?.text = eventPlaces[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.showPlaceDetail(eventPlaces[indexPath.row])
    }
}
