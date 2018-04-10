//
//  FilterVC.swift
//  CU-Days
//
//  Created by Vicente Caycedo on 6/12/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Displays a list of categories for the user to filter events in `FeedVC`.
	`tableSections`: Sections of cells. Each element has a name, which is the section's header, rows, cells within the section, and data, the data associated with the row.
	`collegeFilter`: Events belonging to this college will show in feed.
	`typeFilter`: Events belonging to this type will show in feed.
*/
class FilterVC: UITableViewController
{
	var tableSections = [(name:String, rows:[(cell:UITableViewCell, data:Category)])]()
	static var collegeFilter:Category?
	static var typeFilter:Category?
	var selectedCollegeCell:UITableViewCell?
	var selectedTypeCell:UITableViewCell?
	
	/**
		Sets the table to `grouped` style, the title to "Filter", and creates the table view cells.
	*/
	convenience init()
	{
		self.init(style: .grouped)
		
		title = "Filter"
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(onCancelClick))
		configureTableSections()
	}
	/**
		Sets up the all cells in the table.
	*/
	private func configureTableSections()
	{
		//put colleges in 1st section
		tableSections.append((name: "Colleges", rows:
			UserData.collegeCategories.values.sorted().map({
				category in
				let cell = UITableViewCell.newAutoLayout()
				cell.textLabel?.text = category.name
				return (cell: cell, data: category)
			})
		))
		//put types in 2nd section
		tableSections.append((name: "Types", rows:
			UserData.typeCategories.values.sorted().map({
				category in
				let cell = UITableViewCell.newAutoLayout()
				cell.textLabel?.text = category.name
				return (cell: cell, data: category)
			})
		))
	}
	
    // MARK:- TableView Methods
	
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
        return tableSections[section].name
    }
    override func numberOfSections(in tableView: UITableView) -> Int
	{
        return tableSections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return tableSections[section].rows.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        return tableSections[indexPath.section].rows[indexPath.row].cell
    }
    /**
		Gives the selected cell a checkmark (or removes it) and notify listeners.
		- parameters:
			- tableView: Reference to table.
			- indexPath: Index of selected cell.
	*/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
      	let cellAndData = tableSections[indexPath.section].rows[indexPath.row]
		
		if (cellAndData.data.isCollege)
		{
			selectedCollegeCell?.accessoryType = .none
			cellAndData.cell.accessoryType = .checkmark
			selectedCollegeCell = cellAndData.cell
			FilterVC.collegeFilter = cellAndData.data
		}
		else
		{
			selectedTypeCell?.accessoryType = .none
			cellAndData.cell.accessoryType = .checkmark
			selectedTypeCell = cellAndData.cell
			FilterVC.typeFilter = cellAndData.data
		}
		
		tableView.deselectRow(at: indexPath, animated: true)
		NotificationCenter.default.post(name: .reloadData, object: nil)
    }
	
	/**
		Called when the navigation bar's "Cancel" button is clicked. Removes all filters and notifies listeners.
	*/
	@objc func onCancelClick()
	{
		selectedCollegeCell?.accessoryType = .none
		selectedTypeCell?.accessoryType = .none
		selectedCollegeCell = nil
		selectedTypeCell = nil
		FilterVC.collegeFilter = nil
		FilterVC.typeFilter = nil
		NotificationCenter.default.post(name: .reloadData, object: nil)
	}
	/**
		Returns the events that should be displayed based on the user's selection of filters. To be used by classes that need to update their feeds.
		- parameter events: All the events that need to be filtered.
		- returns: The list of filtered events, in order.
	*/
	static func filter(_ events:[Event]) -> [Event]
	{
		//no filter active
		if (FilterVC.collegeFilter == nil && FilterVC.typeFilter == nil) {
			return events
		}
		
		return events.filter({
			event in
			if (FilterVC.collegeFilter == nil || FilterVC.collegeFilter!.pk == event.collegeCategory) {
				if (FilterVC.typeFilter == nil || FilterVC.typeFilter!.pk == event.typeCategory) {
					return true
				}
			}
			
			return false
		})
	}
}
