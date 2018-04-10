//
//  Event.swift
//  CU-Days
//
//  Created by David Chu on 2017/3/29.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit

/**
	Data-type that holds all information about an event. Designed to be immutable. This will be downloaded from the database via methods in `Internet`, where new events will be compared with saved ones.

	Notable fields are explained below:

	`collegeCategory`: The `Category.pk` of the `Category` this event belongs to.
	`typeCategory`: Same as collegeCategory.
	`date`: The date in which this event BEGINS. If this event crosses over midnight, the date is that of the 1st day.
	`placeId`: String identifying location of event.
	`full`: Is this event full.
	`imagePk`: Pk value of the image this event is linked to.

	- Important: Since events can cross over midnight, the `endTime` may not be "after" the `#startTime`. Calculations should take this into account.

	- Note: see `Category`
*/
struct Event:Hashable, Comparable, JSONObject
{
    let title: String
    let caption: String
    let description: String
    let collegeCategory: Int
	let typeCategory: Int
    let startTime: Time
    let endTime: Time
    let date: Date
	let additional: String
	let placeId: String
	let full: Bool
	let imagePk: Int
    let pk: Int
    
    var hashValue: Int
    {
        return pk
    }
	
	/**
		Creates an event object in-app. This should never be done organically (without initial input from the database in some form), or else we risk becoming out-of-sync with the database.
		- parameters:
			- title: For example, "New Student Check-In"
			- caption: For example, "Bartels Hall"
			- description: For example, "You are required to attend New Student Check-In to pick up..."
			- collegeCategory: See class description.
			- typeCategory: See class description.
			- date: For example, 7/19/2017
			- start: For example, 8:00 AM
			- end: For example, 4:00 PM
			- additional: For example, ART 2701: Introduction to Digital Media
			- placeId: For example, ChIJndqRYRqC0IkR9J8bgk3mDvU
			- full: See class description.
			- imagePk: Unique positive ID given to each image starting from 1.
			- pk: Unique positive ID given to each event starting from 1.
	*/
	init(title:String, caption:String, collegeCategory:Int, typeCategory:Int, pk: Int, start:Time, end:Time, date: Date, description: String, placeId:String, full:Bool, imagePk:Int, additional:String)
    {
        self.title = title
        self.caption = caption
        self.collegeCategory = collegeCategory
		self.typeCategory = typeCategory
        self.description = description
        self.date = date
        self.pk = pk
        startTime = start
        endTime = end
		self.placeId = placeId
		self.full = full
		self.imagePk = imagePk
		self.additional = additional
    }
	/**
		Creates an event object using data downloaded from the database.
		
		- parameter jsonOptional: JSON with the expected keys and values:
				name  => String
				location => String
				pk => int
				description => String
				collegeCategory => int
				typeCategory => int
				start_time => Time. See `Time.fromString()`
				end_time => Time. See `Time.fromString()`
				start_date => Date, formatted as "yyyy-MM-dd"
				placeId => String
				full => boolean
				imagePk => int
				additional => String
	*/
    init?(jsonOptional: [String:Any]?)
    {
        guard let json = jsonOptional,
				let title = json["name"] as? String,
                let pk = json["pk"] as? Int,
                let description = json["description"] as? String,
                let location = json["location"] as? String,
                let startDate = json["start_date"] as? String,
                let startTime = json["start_time"] as? String,
                let endTime = json["end_time"] as? String,
				let placeId = json["place_ID"] as? String,
				let full = json["full"] as? Bool,
				let imagePk = json["image_pk"] as? Int,
				let collegeCategory = json["college_category"] as? Int,
				let typeCategory = json["type_category"] as? Int,
				let additional = json["additional"] as? String else {
			print("Event.jsonOptional: incorrect JSON format")
            return nil
        }
        
        self.pk = pk
        self.title = title
        self.caption = location
        self.description = description
        self.collegeCategory = collegeCategory
		self.typeCategory = typeCategory
		self.placeId = placeId
		self.imagePk = imagePk
		self.full = full
		self.additional = additional
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: startDate) else {
            return nil
        }
        self.date = date
        
        self.startTime = Time.fromString(startTime)
        self.endTime = Time.fromString(endTime)
    }
	
	/**
		Convert this event to a string to save to disk.
		- returns: String representation of this object.
	*/
	func toString() -> String
	{
		let year = UserData.userCalendar.component(.year, from: date)
		let month = UserData.userCalendar.component(.month, from: date)
		let day = UserData.userCalendar.component(.day, from: date)
		return "\(title)|\(caption)|\(description)|\(pk)|\(startTime.hour)|\(startTime.minute)|\(endTime.hour)|\(endTime.minute)|\(full)|\(year)|\(month)|\(day)|\(collegeCategory)|\(typeCategory)|\(placeId)|\(imagePk)|\(additional)"
	}
	
	/**
		Create an event object from its string representation.
		- parameter str: String representation of an event.
		- returns: Event object.
	*/
	static func fromString(str:String) -> Event?
	{
		let parts = str.components(separatedBy: "|")
		guard parts.count == 17,
			let pk = Int(parts[3]),
			let startHour = Int(parts[4]),
			let startMinute = Int(parts[5]),
			let endHour = Int(parts[6]),
			let endMinute = Int(parts[7]),
			let full = Bool(parts[8]),
			let year = Int(parts[9]),
			let month = Int(parts[10]),
			let day = Int(parts[11]),
			let collegeCategory = Int(parts[12]),
			let typeCategory = Int(parts[13]),
			let imagePk = Int(parts[15]) else {
			print("invalid event string: \(str)")
			return nil
		}
		
		let title = parts[0]
		let caption = parts[1]
		let description = parts[2]
		let placeId = parts[14]
		let additional = parts[16]
		
		let start = Time(hour: startHour, minute: startMinute)
		let end = Time(hour: endHour, minute: endMinute)
		var dateComponents = DateComponents()
		dateComponents.year = year
		dateComponents.month = month
		dateComponents.day = day
		let date = UserData.userCalendar.date(from: dateComponents)!
		
		return Event(title: title, caption: caption, collegeCategory: collegeCategory, typeCategory: typeCategory, pk: pk, start: start, end: end, date: date, description: description, placeId: placeId, full: full, imagePk: imagePk, additional: additional)
	}
	
	/**
		Returns the date as "DayOfWeek, Month DayOfMonth".
		For example, "Saturday, Aug 18".
	*/
	func readableDate() -> String
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE, MMM d"
		return dateFormatter.string(from: date)
	}
}
/**
	Returns whether lhs == rhs. True if `pk`s are identical.
	- parameters:
		- lhs: `Event` on left of ==
		- rhs: `Event` on right of ==
	- returns: See description.
*/
func == (lhs:Event, rhs:Event) -> Bool
{
    return lhs.pk == rhs.pk
}
/**
	Returns whether lhs < rhs. Ordering is based on start time, taking into account events that may start after midnight.
	- parameters:
		- lhs: `Event` on left of <
		- rhs: `Event` on right of <
	- returns: True if lhs < rhs.
*/
func < (lhs:Event, rhs:Event) -> Bool
{
	let dateCompare = UserData.userCalendar.compare(lhs.date, to: rhs.date, toGranularity: .day)
	if (dateCompare != .orderedSame)
	{
		return dateCompare == .orderedAscending
	}
	
	//If lhs starts in the next day and rhs in the previous
	if (lhs.startTime.hour <= ScheduleVC.END_HOUR && rhs.startTime.hour >= ScheduleVC.START_HOUR)
	{
		return false
	}
	//If lhs starts in the previous day and rhs in the next
	if (lhs.startTime.hour >= ScheduleVC.START_HOUR && rhs.startTime.hour <= ScheduleVC.END_HOUR)
	{
		return true
	}
	return lhs.startTime < rhs.startTime
}
