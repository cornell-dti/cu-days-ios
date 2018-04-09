//
//  UserData.swift
//  CU-Days
//
//  Created by Vicente Caycedo on 4/28/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import Foundation
import CoreData
import UIKit

/**
	Handles all data shared between classes. Many of these variables have associated `NotificationCenter` events that should be fired when they are changed, so do so when changing their values.

	`allEvents`: All events on disk with PKs as keys.
	`selectedEvents`: All events selected by the user with PKs as keys.
	`collegeCategories`: All categories representing colleges with PKs as keys.
	`typeCategories`: All categories representing types with PKs as keys.
	`DATES`: Dates of the orientation.
	`selectedDate`: The date to display events for.
*/
class UserData
{
    //UserDefaults keys
    static let addedPKsName = "AddedPKs" //KeyPath used for accessing added PKs
	static let versionName = "version" //KeyPath used for accessing local version to compare with database
    
    //Events
	static var allEvents = [Date: [Int:Event]]()
	static var selectedEvents = [Date: [Int:Event]]()
    
    //Calendar for manipulating dates. You can use this throughout the app.
    static let userCalendar = Calendar.current
    
    //Dates
    static var DATES = [Date]()
	static var selectedDate:Date!
	static let YEAR = 2018
	static let MONTH = 4
	static let DAYS = [12,13,16,19,20,23]
	
	//Categories
	static var collegeCategories = [Int:Category]()
	static var typeCategories = [Int:Category]()
	
    private init(){}
	
	/**
		Initialize `DATES` and lists for dictionaries of events
	*/
	private static func initDates()
	{
		let today = Date()
		var dateComponents = DateComponents()
		dateComponents.year = YEAR
		dateComponents.month = MONTH
		dateComponents.day = DAYS[0]
		
		selectedDate = UserData.userCalendar.date(from: dateComponents)!
		
		//this assumes END_DAY is larger than START_DAY
		for day in DAYS
		{
			dateComponents.day = day
			let date = UserData.userCalendar.date(from: dateComponents)!
			DATES.append(date)
			selectedEvents[date] = [Int:Event]()
			allEvents[date] = [Int:Event]()
			
			if (UserData.userCalendar.compare(today, to: date, toGranularity: .day) == .orderedSame)
			{
				selectedDate = date
			}
		}
	}
	/**
		Instantiates `allEvents`, `selectedEvents`, `categories` by reading from CoreData and interacting with the database.
	
		- note: Call whenever the app enters foreground or is launched.
	
		1. Retrieves all events and categories from `CoreData`, adding them to `allEvents`, `categories`.
		2. Sorts all events and categories. This is because downloading is done in the background, and before we've finished downloading, the UI may already need to display events & categories.
		3. Downloads updates from the database; updates categories & events.
		4. Retrieves selected events.
		5. If the user has reminders turned on, remove all deleted events' notifications, and update the updated events' notifications.
		6. Tell the user which of their selected events have been updated.
		7. Sort again with updated events.
		8. Save new database version.
	*/
	static func loadData()
	{
		initDates()
		
		//load from CoreData
		let eventData = fetchFromCoreData(Event.self)
		eventData.forEach({appendToAllEvents(Event($0))})
		
		let categoryData = fetchFromCoreData(Category.self)
		for datum in categoryData
		{
			let category = Category(datum)
			if (category.isCollege) {
				collegeCategories[category.pk] = category
			}
			else {
				typeCategories[category.pk] = category
			}
		}
		
		let addedPKs = getAddedPKs()
		addedPKs.forEach({pk in
			if let event = eventFor(pk) {
				insertToSelectedEvents(event)
			}
		})
		
		//access database for updates
		Internet.getUpdatesForVersion(version, onCompletion:
		{
			newVersion, changedCategories, deletedCategoryPks, changedEvents, deletedEventPks in
			
			//update categories
			changedCategories.forEach({updateCategory($0)})
			deletedCategoryPks.forEach({removeFromCoreData(entityName: Category.entityName, pk: $0)})
			deletedCategoryPks.forEach({pk in
				collegeCategories.removeValue(forKey: pk)
				typeCategories.removeValue(forKey: pk)
			})
			
			//update events
			changedEvents.forEach({updateEvent($0)})
			deletedEventPks.forEach({
				eventPk in
				UserData.removeFromCoreData(entityName: Event.entityName, pk: eventPk)
			})
			for date in DATES
			{
				deletedEventPks.forEach({pk in
					allEvents[date]?.removeValue(forKey: pk)
					selectedEvents[date]?.removeValue(forKey: pk)
				})
			}
			
			//all version updates have been processed. Now, load events that the user has selected into selectedEvents (again).
			addedPKs.forEach({pk in
				if let event = eventFor(pk) {
					insertToSelectedEvents(event)
				}
			})
			
			//delete and resend notifications
			let changedSelectedEvents = changedEvents.filter({addedPKs.contains($0.pk)})
			if (BoolPreference.Reminder.isTrue())
			{
				deletedEventPks.forEach({LocalNotifications.removeNotification(for: $0)})
				changedSelectedEvents.forEach({LocalNotifications.createNotification(for: $0)})
			}
			
			//notify user of event updates
			LocalNotifications.addNotification(for: changedSelectedEvents)
			
			//save updated database version
			version = newVersion
		})
	}
	
    // MARK:- Search Functions

	/**
		Returns whether or not the event is in `allEvents`.
		- parameter event: Event to check.
		- returns: True if `allEvents` already holds a copy of the given event.
	*/
    static func allEventsContains(_ event: Event) -> Bool
	{
        if let eventsForDate = allEvents[event.date] {
            return eventsForDate[event.pk] != nil
        } else {
            return false
        }
    }
	/**
		Returns true if the event is selected.
		- parameter event: The event that we want to check is selected.
		- returns: See method description.
	*/
    static func selectedEventsContains(_ event: Event) -> Bool
	{
        if let setForDate = selectedEvents[event.date] {
            return setForDate[event.pk] != nil
        } else {
            return false
        }
    }
	/**
		Adds event to `allEvents` for the correct date according to `event.date`.
		The date should match a date in `DATES`.
		- parameter event: Event to add.
	*/
    static func appendToAllEvents(_ event: Event)
	{
		guard allEvents[event.date] != nil else {
			print("appendToAllEvents: attempted to add event with date outside orientation")
			return
		}
		allEvents[event.date]![event.pk] = event
    }
	/**
		Adds event to `selectedEvents`. The date should match a date in `DATES`.
		- parameter event: Event to add.
		- returns: True if the event was added
	*/
    static func insertToSelectedEvents(_ event: Event)
	{
		guard selectedEvents[event.date] != nil else {
			print("insertToSelectedEvents: attempted to add event with date outside orientation")
			return
		}
		selectedEvents[event.date]![event.pk] = event
    }
	/**
		Removes event from `selectedEvents`.
		- parameter event: Event to remove.
		- returns: True IFF an event was actually removed.
	*/
	@discardableResult
    static func removeFromSelectedEvents(_ event: Event) -> Bool
	{
        if selectedEvents[event.date] != nil
		{
            return selectedEvents[event.date]!.removeValue(forKey: event.pk) != nil
        }
		return false
    }
	/**
		Removes event from `allEvents`.
		- parameter event: Event to remove.
		- returns: True IFF an event was actually removed.
	*/
	@discardableResult
	static func removeFromAllEvents(_ event:Event) -> Bool
	{
		if allEvents[event.date] != nil
		{
			return allEvents[event.date]!.removeValue(forKey: event.pk) != nil
		}
		return false
	}
	/**
		Linear search for a event given its pk value.
		- parameter pk: `Event.pk`
		- returns: Event, nil if no match was found.
	*/
	static func eventFor(_ pk:Int) -> Event?
	{
		return allEvents.values.first(where: {$0[pk] != nil})?[pk]
	}
	/**
		Returns the list of sorted events for the given date.
		- parameter date: Date of events
		- returns: Event array, nil if the date was invalid
	*/
	static func sortedEvents(for date:Date) -> [Event]?
	{
		return allEvents[date]?.values.sorted()
	}
	/**
		Updates an event that might've been already on disk with one from the database. Performs the following actions:
	
		1. Adds new event.
		2. Removes old event from `CoreData` (again, using the `pk`. Look at `removeFromCoreData()` for details).
		3. Saves new event to `CoreData`.
		4. Attempt to remove old event from selected events. If we did remove something, that means the old event was selected, so we should then select the new updated event. `removeFromSelected()` also matches event by equality, which is based on `pk`.
	
		- note: Pictures CANNOT be updated with this method (for now). To update an event's picture, the best way would be to delete the event and add a new one (both done on the database), with a different pk.
		- parameter event: Updated event. Should have same `pk` as old event, if old event exists.
	*/
	static func updateEvent(_ event:Event)
	{
		removeFromAllEvents(event)
		appendToAllEvents(event)
		removeFromCoreData(entityName: Event.entityName, pk: event.pk)
		saveToCoreData(event)
		
		//if the event was selected, make sure it still is. Otherwise, we don't care.
		if (removeFromSelectedEvents(event))
		{
			insertToSelectedEvents(event)
		}
	}
	/**
		Updates a category that might've been already on disk with one from the database. Performs the following actions:
	
		1. Remove the old category from `CoreData`.
		2. Adds new category.
		3. Saves new category to `CoreData`.
		
		- parameter category: Updated category. Should have same `pk` as old category, if old category exists.
	*/
	static func updateCategory(_ category:Category)
	{
		removeFromCoreData(entityName: Category.entityName, pk: category.pk)
		if (category.isCollege) {
			collegeCategories[category.pk] = category
		}
		else {
			typeCategories[category.pk] = category
		}
		saveToCoreData(category)
	}
	
	// MARK:- Core Data interactions
	
	/**
		Saves the given object to `CoreData` asynchronously.
		- parameter object: Object to save. Should implement `CoreDataObject` protocol.
	*/
	static func saveToCoreData(_ object:CoreDataObject)
	{
		CoreData.persistentContainer.performBackgroundTask(
		{
			(context) in
			let entity = NSEntityDescription.entity(forEntityName: type(of: object).entityName, in: context)!
			object.saveToCoreData(entity: entity, context: context)
			try? context.save()
		})
	}
	/**
		Removes an object with the `pk` from `CoreData`.
		- parameters:
 			- entityName: Type of object.
			- pk: Unique id of object.
	*/
	static func removeFromCoreData(entityName:String, pk:Int)
	{
		CoreData.persistentContainer.performBackgroundTask(
		{
			(context) in
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			fetchRequest.predicate = NSPredicate(format: "pk = %@", argumentArray: [pk])
			let fetchedResults = try? context.fetch(fetchRequest)
			fetchedResults?.forEach({context.delete($0 as! NSManagedObject)})
		})
	}
	/**
		Returns an array of `NSManagedObjects` from `CoreData` of the given type.
		- parameter type: The entity type of the objects you want to read.
		- returns: Array of `NSManagedObjects` of the entity type given.
	*/
	private static func fetchFromCoreData(_ type:CoreDataObject.Type) -> [NSManagedObject]
	{
		let managedContext = CoreData.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
		return try! managedContext.fetch(fetchRequest)
	}
	
	// MARK:- Image saving, reading, and deletion.
	
	/**
		Saves the given `UIImage` on the iPhone with a `.png` extension.
		
		- parameters:
			- image: Image to save.
			- imagePk: Unique id of image.
	*/
	static func saveImage(_ image:UIImage, imagePk:Int)
	{
		let imageData = UIImagePNGRepresentation(image)
		let url = documentURLForName("\(imagePk).png")
		try? imageData?.write(to: url)
	}
	/**
		Reads from disk an image for the given id.
	
		- parameter imagePk: Unique id of image.
		- returns: Image if one was found, nil otherwise.
	*/
	static func loadImageFor(_ imagePk:Int) -> UIImage?
	{
		let url = documentURLForName("\(imagePk).png")
		return UIImage(contentsOfFile: url.path)
	}
	/**
		Provides a path to the file for the given file name.
		- parameter name: Name of the file.
		- returns: Path to the file.
	*/
	private static func documentURLForName(_ name:String) -> URL
	{
		let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[0].appendingPathComponent(name)
	}
	
	
	// MARK:- UserDefaults interactions
	
	/**
		Retrieves from `UserDefaults` a list of `event.pk`s of events the user has selected.
		- returns: List of `pk`s belonging to selected events.
	*/
	static func getAddedPKs() -> [Int]
	{
		let defaults = UserDefaults.standard
		return defaults.object(forKey: addedPKsName) as? [Int] ?? [Int]()
	}
	/**
		Saves to `UserDefaults` the `event.pk`s of events the user has selected.
	*/
    static func saveAddedPKs()
	{
        let defaults = UserDefaults.standard
        let addedPks = selectedEvents.values.flatMap({$0.keys})
        defaults.set(addedPks, forKey: addedPKsName)
    }
	/**
		The version of the database we have saved on this phone. This value is passed to the database to determine what needs to be updated. This value is then synchronized with the database's current version.
	*/
	static var version:Int {
		get
		{
			//if version was not set, defaults.integer returns 0, which is what we want
			let defaults = UserDefaults.standard
			return defaults.integer(forKey: versionName)
		}
		set
		{
			let defaults = UserDefaults.standard
			defaults.set(newValue, forKey: versionName)
		}
	}
}
