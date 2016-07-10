//
//  FilterViewController.swift
//  select_assignment2_flicks
//
//  Created by Hoa Tran on 7/10/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import SnapKit

//MARK: -Constants
extension FilterViewController {
    @nonobjc static let CONTENT_CONTROL_INDEX = 0
    
    @nonobjc static let YEAR_FILTERS_INDEX = 1
    
    @nonobjc static let RELEASE_YEAR_FILTER_INDEX = 0
    
    @nonobjc static let PRIMARY_RELEASE_YEAR_FILTER_INDEX = 1
    
    @nonobjc static let NUMBER_OF_OPTIONS_IN_CONTENT_CONTROL = 1
    
    @nonobjc static let NUMBER_OF_OPTIONS_IN_YEAR_FILTERS = 2
    
    @nonobjc static let NUMBER_OF_FILTERS_SECTION = 2
    
    @nonobjc static let PICKER_YEAR_COMPONENT = 0
    
    //only year field
    @nonobjc static let PICKER_YEAR_NUMBER_OF_COMPONENTS = 1
}

class FilterViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var switchShowAdult: UISwitch!
    
    @IBOutlet weak var stackShowAdultContent: UIStackView!
    
    @IBOutlet weak var pickerReleaseYear: UIPickerView!
    
    @IBOutlet weak var pickerPrimaryReleaseYear: UIPickerView!
    
    @IBOutlet weak var stackPrimaryReleaseYear: UIStackView!
    
    @IBOutlet weak var stackReleaseYear: UIStackView!
    
    
    var delegate: FilterViewControllerDelegate?
    
    var datasource: FilterViewControllerDataSource?
    
    override func viewDidLoad() {
        self.navigationItem.title = "Filters"
        tableView.delegate = self
        tableView.dataSource = self
        
        stackShowAdultContent.snp_makeConstraints { (make) in
        }
        
        pickerReleaseYear.dataSource = self
        
        pickerReleaseYear.delegate = self
        
        pickerPrimaryReleaseYear.dataSource = self
        
        pickerPrimaryReleaseYear.delegate = self
        
        
        if let datasource = datasource {
            switchShowAdult.on = datasource.showAdultContent()
            pickerReleaseYear.selectRow(ApiClient.getPickerYearIndex(datasource.releaseYear()), inComponent: FilterViewController.PICKER_YEAR_COMPONENT, animated: false)
            pickerPrimaryReleaseYear.selectRow(ApiClient.getPickerYearIndex(datasource.primaryReleaseYear()), inComponent: FilterViewController.PICKER_YEAR_COMPONENT, animated: false)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        guard delegate != nil else {
            return
        }
        delegate?.filterViewController(switchShowAdult.on, releaseYear: ApiClient.getApiYearValue(pickerReleaseYear.selectedRowInComponent(0)), primaryReleaseYear: ApiClient.getApiYearValue( pickerPrimaryReleaseYear.selectedRowInComponent(0)))
    }
    
}

//MARK: -Picker methods
extension FilterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return FilterViewController.PICKER_YEAR_NUMBER_OF_COMPONENTS
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Any"
        }
        return String(Constants.YEARS[row - 1])
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.YEARS.count + 1
    }
}

protocol FilterViewControllerDelegate {
    func filterViewController(showAdultContent: Bool, releaseYear: Int?, primaryReleaseYear: Int?)
}

protocol FilterViewControllerDataSource {
    func showAdultContent() -> Bool
    func releaseYear() -> Int?
    func primaryReleaseYear() -> Int?
}

//MARK: -tableview methods
extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case FilterViewController.CONTENT_CONTROL_INDEX:
            return FilterViewController.NUMBER_OF_OPTIONS_IN_CONTENT_CONTROL
        case FilterViewController.YEAR_FILTERS_INDEX:
            return FilterViewController.NUMBER_OF_OPTIONS_IN_YEAR_FILTERS
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case FilterViewController.CONTENT_CONTROL_INDEX:
            return "Content Control"
        case FilterViewController.YEAR_FILTERS_INDEX:
            return "Year Filters"
        default:
            return ""
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FilterViewController.NUMBER_OF_FILTERS_SECTION
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        switch indexPath.section {
        case FilterViewController.CONTENT_CONTROL_INDEX:
            cell.addSubview(stackShowAdultContent)
            stackShowAdultContent.snp_makeConstraints(closure: { (make) in
                make.center.equalTo(cell)
            })
            stackShowAdultContent.spacing = cell.frame.width - stackShowAdultContent.subviews[0].frame.width - stackShowAdultContent.subviews[1].frame.width
        case FilterViewController.YEAR_FILTERS_INDEX:
            switch indexPath.row {
            case FilterViewController.RELEASE_YEAR_FILTER_INDEX:
            cell.addSubview(stackReleaseYear)
            stackReleaseYear.snp_makeConstraints(closure: { (make) in
                make.center.equalTo(cell)
            })
            stackReleaseYear.spacing = cell.frame.width - stackReleaseYear.subviews[0].frame.width - stackReleaseYear.subviews[1].frame.width
            case FilterViewController.PRIMARY_RELEASE_YEAR_FILTER_INDEX:
                cell.addSubview(stackPrimaryReleaseYear)
                stackPrimaryReleaseYear.snp_makeConstraints(closure: { (make) in
                    make.center.equalTo(cell)
                })
                stackPrimaryReleaseYear.spacing = cell.frame.width - stackPrimaryReleaseYear.subviews[0].frame.width - stackPrimaryReleaseYear.subviews[1].frame.width
            default:
                break
            }
        default:
            break
        }
        cell.selectionStyle = .None
        return cell
    }
}
