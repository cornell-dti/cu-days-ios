//
//  Category.swift
//  CU-Days
//
//  Created by David Chu on 2017/6/23.
//  Copyright © 2017年 Cornell D&TI. All rights reserved.
//

import Foundation

/**
	The category that an `Event` belongs in. This will be downloaded from the database via methods in `Internet`, where new categories will be compared with saved ones. More in the constructor below.
	- Note: See `Event`
*/
struct Category:Hashable, Comparable, JSONObject
{
	let pk:Int
	let name:String
	let description:String
	let isCollege:Bool
	
	var hashValue: Int
	{
		return pk
	}
	
	/**
		Creates a category object in-app. This should never be done organically (without initial input from the database in some form), or else we risk becoming out-of-sync with the database.
		
		- parameters:
			- pk: Unique positive ID given to each category starting from 1.
			- name: For example, "College of Engineering".
			- description: More information about a `Category`. Currently unused.
			- isCollege: True if this is a college category, false if it's a type category.
	*/
	init(pk:Int, name:String, description:String, isCollege:Bool)
	{
		self.pk = pk
		self.name = name
		self.description = description
		self.isCollege = isCollege
	}
	/**
		Creates a category object using data downloaded from the database.

		- parameter jsonOptional: JSON with the expected keys and values:
				pk => Int
				category => String
				description => String
				isCollege => String
	*/
	init?(jsonOptional: [String:Any]?)
	{
		guard let json = jsonOptional,
			let pk = json["pk"] as? Int,
			let name = json["category"] as? String,
			let description = json["description"] as? String,
			let isCollege = json["isCollege"] as? Bool else {
				return nil
		}
		
		self.init(pk:pk, name:name, description:description, isCollege: isCollege)
	}
	
	/**
		Convert this category to a string to save to disk.
		- returns: String representation of this object.
	*/
	func toString() -> String
	{
		return "\(pk)|\(name)|\(description)|\(isCollege)"
	}
	/**
		Create a category object from its string representation.
		- parameter str: String representation of a category.
		- returns: Category object.
	*/
	static func fromString(str:String) -> Category?
	{
		let parts = str.components(separatedBy: "|")
		guard parts.count == 4,
			let pk = Int(parts[0]),
			let isCollege = Bool(parts[3]) else {
			print("invalid saved category: \(str)")
			return nil
		}
		
		let name = parts[1]
		let description = parts[2]
		return Category(pk: pk, name: name, description: description, isCollege: isCollege)
	}
}
/**
	Returns whether lhs == rhs. True if `pk`s are identical.
	- parameters:
		- lhs: `Category` on left of ==
		- rhs: `Category` on right of ==
	- returns: See description.
*/
func == (lhs:Category, rhs:Category) -> Bool
{
	return lhs.pk == rhs.pk
}
/**
	Returns whether lhs < rhs. Ordering is based on name.
	- parameters:
		- lhs: `Category` on left of <
		- rhs: `Category` on right of <
	- returns: True if lhs < rhs.
*/
func < (lhs:Category, rhs:Category) -> Bool
{
	return lhs.name.compare(rhs.name) == .orderedAscending
}
