//
//  DetailsVC.swift
//  CU-Days
//
//  Created by Vicente Caycedo on 3/13/17.
//  Copyright © 2017 Cornell D&TI. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import PKHUD

/**
	Displays a user-selected event.

	`event`: The event displayed to the user.
	`placeLatLng`: Latitude and longitude of the place in `event.placeId`.

	`changed`: Indicates if the user selected/deselected the event. When this view is exiting, if this is true, then we must notify listeners for event reloads.
	`didLayout`: True if layout of subviews was completed. Used to ensure layout is only done once.
	`didSetListeners`: True if listeners for subviews were set. Used to ensure listeners are only set once.
	`configure(event)`: Method to configure this VC to display the given event. Must be called before presenting to the user.
*/
class DetailsVC: UIViewController
{
	let scrollView = UIScrollView.newAutoLayout()
	let scrollContent = UIStackView.newAutoLayout()
	
	let eventImage = UIImageView.newAutoLayout()
    let eventTitle = UILabel.newAutoLayout()
	
	let eventTime = UILabel.newAutoLayout()
    let eventLocation = UILabel.newAutoLayout()
	let addButton = UILabel.newAutoLayout()
	
	let fullContainer = UIView.newAutoLayout()
	let fullDivider = UIView.newAutoLayout()
	let fullLabel = UITextField.newAutoLayout()
	let fullDescription = UILabel.newAutoLayout()
	
    let eventDescription = UILabel.newAutoLayout()
	let moreButton = UILabel.newAutoLayout()
	let moreButtonGradient = GradientView.newAutoLayout()
	let additional = UILabel.newAutoLayout()
	
	let map = GMSMapView.newAutoLayout()
	var mapMarker:GMSMarker?
	let directionsButton = UIButton(type: .system)
	
	let NUM_LINES_IN_CONDENSED_DESCRIPTION = 3
	let placesClient = GMSPlacesClient.shared()
    var event: Event?
	var placeLatLng: CLLocationCoordinate2D?
    var changed = false
	var didLayout = false
	var didSetListeners = false
	
	/**
		Call this to manually initialize.
	*/
	convenience init()
	{
		self.init(nibName: nil, bundle: nil)
	}
	/**
		Show the event's data on screen.
	*/
    override func viewDidLoad()
	{
        super.viewDidLoad()
		if (!didSetListeners)
		{
			didSetListeners = true
			addButton.isUserInteractionEnabled = true
			addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onAddButtonClick(_:))))
			moreButton.isUserInteractionEnabled = true
			moreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onMoreButtonClick(_:))))
			directionsButton.addTarget(self, action: #selector(onDirectionsButtonClick(_:)), for: .touchUpInside)
		}
    }
    /**
		Notify listeners if the event's selection has been changed by the user.
		- parameter animated: Ignored.
	*/
    override func viewWillDisappear(_ animated: Bool)
	{
        if (changed)
		{
            NotificationCenter.default.post(name: .reloadData, object: nil)
        }
    }
	/**
		Sets contraints for all subviews.
	*/
	override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		
		//only layout once
		guard !didLayout else {
			return
		}
		didLayout = true
		
		view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewEdges()
		scrollView.backgroundColor = UIColor.white
		scrollView.addSubview(scrollContent)
		scrollContent.autoPinEdgesToSuperviewEdges()
		scrollContent.alignment = .fill
		scrollContent.axis = .vertical
		scrollContent.spacing = Layout.MARGIN
		
		
		//eventImageContainer will hold eventImage, eventImageGradient, and eventTitle
		//	|--------|
		//	|        |
		//	| Title  |
		//	|--------|
		let eventImageContainer = UIView.newAutoLayout()
		scrollContent.addArrangedSubview(eventImageContainer)
		eventImageContainer.autoMatch(.width, to: .width, of: view)
		eventImageContainer.autoMatch(.height, to: .width, of: eventImageContainer, withMultiplier: 3/4)
		
		eventImageContainer.addSubview(eventImage)
		eventImage.autoPinEdgesToSuperviewEdges()
		
		let eventImageGradient = GradientView.newAutoLayout()
		eventImageContainer.addSubview(eventImageGradient)
		eventImageGradient.autoMatch(.height, to: .height, of: eventImageContainer, withMultiplier: 0.5)
		eventImageGradient.autoPinEdge(toSuperviewEdge: .left)
		eventImageGradient.autoPinEdge(toSuperviewEdge: .right)
		eventImageGradient.autoPinEdge(toSuperviewEdge: .bottom)
		eventImageGradient.alpha = 0.6
		eventImageGradient.setGradient(colors: [UIColor.clear.cgColor, UIColor.black.cgColor], orientation: .topToBottom)
		
		eventImageContainer.addSubview(eventTitle)
		eventTitle.autoPinEdge(toSuperviewEdge: .left, withInset: Layout.MARGIN)
		eventTitle.autoPinEdge(toSuperviewEdge: .right, withInset: Layout.MARGIN)
		eventTitle.autoPinEdge(toSuperviewEdge: .bottom, withInset: Layout.MARGIN)
		eventTitle.font = UIFont(name: Font.DEMIBOLD, size: 22)
		eventTitle.numberOfLines = 0
		eventTitle.textAlignment = .left
		eventTitle.textColor = UIColor.white
		
		
		//metadataContainer will hold eventTime, eventLocation, and addButton
		//
		// 10:00 AM - 12:30 PM		|-----|
		//							| Add |
		// Schoellkopf Stadium		|-----|
		//
		//marginedContent holds all contents that should have uniform left & right margin.
		let marginedContent = UIStackView.newAutoLayout()
		scrollContent.addArrangedSubview(marginedContent)
		marginedContent.alignment = .fill
		marginedContent.axis = .vertical
		marginedContent.spacing = Layout.MARGIN
		marginedContent.layoutMargins = UIEdgeInsets(top: 0, left: Layout.MARGIN, bottom: 0, right: Layout.MARGIN)
		marginedContent.isLayoutMarginsRelativeArrangement = true
		
		let metadataContainer = UIView.newAutoLayout()
		marginedContent.addArrangedSubview(metadataContainer)
		
		metadataContainer.addSubview(eventTime)
		eventTime.autoPinEdge(toSuperviewEdge: .top)
		eventTime.autoPinEdge(toSuperviewEdge: .left)
		eventTime.font = UIFont(name: Font.MEDIUM, size: 16)
		
		metadataContainer.addSubview(eventLocation)
		eventLocation.autoPinEdge(.top, to: .bottom, of: eventTime, withOffset: 2)
		eventLocation.autoPinEdge(.left, to: .left, of: eventTime)
		eventLocation.autoPinEdge(toSuperviewEdge: .bottom)
		eventLocation.font = UIFont(name: Font.REGULAR, size: 14)
		eventLocation.alpha = 0.5
		eventLocation.numberOfLines = 0
		
		metadataContainer.addSubview(addButton)
		addButton.autoPinEdge(toSuperviewEdge: .right)
		addButton.autoPinEdge(toSuperviewEdge: .top)
		addButton.autoPinEdge(.left, to: .right, of: eventLocation, withOffset: Layout.MARGIN, relation: .greaterThanOrEqual)
		addButton.autoSetDimensions(to: CGSize(width: 100, height: 40))
		addButton.layer.borderWidth = 2
		addButton.layer.borderColor = Colors.RED.cgColor
		addButton.layer.cornerRadius = 10
		addButton.textColor = Colors.RED
		addButton.textAlignment = .center
		addButton.font = UIFont(name: Font.DEMIBOLD, size: 16)
		
		
		//fullContainer will hold fullLabel, fullDescription
		//
		// (Full) The event is full.
		//
		add(divider: fullDivider, to: marginedContent)
		marginedContent.addArrangedSubview(fullContainer)
		fullContainer.autoSetDimension(.height, toSize: 40)
		
		fullContainer.addSubview(fullLabel)
		fullLabel.autoPinEdge(toSuperviewEdge: .left)
		fullLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
		fullLabel.autoSetDimensions(to: CGSize(width: 48, height: 32))
		fullLabel.isUserInteractionEnabled = false
		fullLabel.textAlignment = .center
		fullLabel.textColor = UIColor.white
		fullLabel.text = "FULL"
		fullLabel.font = UIFont(name: Font.DEMIBOLD, size: 14)
		fullLabel.layer.cornerRadius = 16
		fullLabel.backgroundColor = Colors.RED
		
		fullContainer.addSubview(fullDescription)
		fullDescription.autoPinEdge(toSuperviewEdge: .right)
		fullDescription.autoPinEdge(.left, to: .right, of: fullLabel, withOffset: Layout.MARGIN)
		fullDescription.autoAlignAxis(toSuperviewAxis: .horizontal)
		fullDescription.font = UIFont(name: Font.MEDIUM, size: 14)
		fullDescription.numberOfLines = 0
		fullDescription.text = "The event is full."
		
		
		//detailsContainer will hold eventDescription, moreButton, and moreButtonMask
		//----------------------
		// Additional info
		//
		// Details is very very long
		// but the remaining text will
		// be exposed if you cli [more]
		//
		addDivider(to: marginedContent)
		
		marginedContent.addArrangedSubview(additional)
		additional.numberOfLines = 0
		
		let detailsContainer = UIView.newAutoLayout()
		marginedContent.addArrangedSubview(detailsContainer)
		
		detailsContainer.addSubview(eventDescription)
		eventDescription.autoPinEdgesToSuperviewEdges()
		eventDescription.font = UIFont(name: Font.REGULAR, size: 14)
		eventDescription.textColor = Colors.LIGHT_GRAY
		
		detailsContainer.addSubview(moreButton)
		moreButton.autoPinEdge(toSuperviewEdge: .bottom)
		moreButton.autoPinEdge(toSuperviewEdge: .right)
		moreButton.font = UIFont(name: Font.MEDIUM, size: 14)
		moreButton.backgroundColor = UIColor.white
		moreButton.textColor = Colors.RED
		moreButton.text = "more"
		
		detailsContainer.addSubview(moreButtonGradient)
		moreButtonGradient.autoPinEdge(.right, to: .left, of: moreButton)
		moreButtonGradient.autoPinEdge(toSuperviewEdge: .bottom)
		moreButtonGradient.autoMatch(.width, to: .width, of: moreButton)
		moreButtonGradient.autoMatch(.height, to: .height, of: moreButton)
		moreButtonGradient.setGradient(colors: [UIColor(white: 1, alpha: 0).cgColor, UIColor.white.cgColor], orientation: .leftToRight)
		
		//mapContainer will hold map, mapBanner, and directionsButton
		//|----------------|
		//|                |
		//|----------------|
		//|     Directions |
		//|----------------|
		let mapContainer = UIView.newAutoLayout()
		scrollContent.addArrangedSubview(mapContainer)
		mapContainer.autoMatch(.height, to: .width, of: mapContainer, withMultiplier: 9/16)
		
		mapContainer.addSubview(map)
		map.autoPinEdgesToSuperviewEdges()
		
		let mapBanner = UIView.newAutoLayout()
		mapContainer.addSubview(mapBanner)
		mapBanner.autoSetDimension(.height, toSize: 40)
		mapBanner.autoPinEdge(toSuperviewEdge: .left)
		mapBanner.autoPinEdge(toSuperviewEdge: .right)
		mapBanner.autoPinEdge(toSuperviewEdge: .bottom)
		mapBanner.alpha = 0.8
		mapBanner.backgroundColor = UIColor.white
		mapBanner.layer.borderWidth = 1
		mapBanner.layer.borderColor = Colors.GRAY.cgColor
		
		mapContainer.addSubview(directionsButton)
		directionsButton.autoPinEdge(toSuperviewEdge: .right, withInset: Layout.MARGIN)
		directionsButton.autoAlignAxis(.horizontal, toSameAxisOf: mapBanner)
		directionsButton.setTitle("Directions", for: .normal)
	}
	/**
		Helper for `add(divider, to stack)`. Use this function when you don't want to provide a UIView as the divider.
		- parameter stack: Stack where the divider will be added.
	*/
	private func addDivider(to stack:UIStackView)
	{
		add(divider: UIView.newAutoLayout(), to: stack)
	}
	/**
		Configures the given divider and puts it in the given stack as the next subview.
		- parameters:
			- divider: A UIView that will become a subview of the given stack.
			- stack: Stack where the divider will be added.
	*/
	private func add(divider:UIView, to stack:UIStackView)
	{
		stack.addArrangedSubview(divider)
		divider.autoSetDimension(.height, toSize: 1)
		divider.backgroundColor = Colors.GRAY
	}
	
    /**
		Shows the event's data on screen. Attempts to retrieve an image from the database or from saved files. This method must be called before this VC is shown to the user.
		- parameter event: Same as the global variable, but not nil.
	*/
    func configure(event:Event)
    {
		self.event = event
		
		title = event.readableDate()
		
        eventTitle.text = event.title
        eventLocation.text = event.caption
        eventDescription.text = event.description
		eventTime.text = "\(event.startTime) - \(event.endTime)"
		
        refreshButton(added: UserData.selectedEventsContains(event))
		Internet.getImageFor(event.imagePk, imageView: eventImage)
		configureMap(event:event)
		configureFull(event: event)
		configureDescription(event: event)
    }
	/**
		Truncates `eventDescription` and shows `moreButton` and `moreButtonGradient` depending on how long the event's description is.
		Show additional info if there is any available.
		- parameter event: Same as the global variable, but not nil.
	*/
	private func configureDescription(event:Event)
	{
		//Assumes that the description's width is as follows. Will need to be updated accordingly.
		let descriptionWidth = view.frame.width - Layout.MARGIN * 2
		if (eventDescription.visibleNumberOfLines(textWidth: descriptionWidth) > NUM_LINES_IN_CONDENSED_DESCRIPTION)
		{
			//show "more"
			moreButton.isHidden = false
			moreButtonGradient.isHidden = false
			eventDescription.numberOfLines = 3
		}
		else
		{
			//hide "more"
			moreButton.isHidden = true
			moreButtonGradient.isHidden = true
			eventDescription.numberOfLines = 0
		}
		
		if (!event.additional.isEmpty)
		{
			additional.text = event.additional
			additional.isHidden = false
		}
		else
		{
			additional.isHidden = true
		}
	}
	/**
		Set up the required label and description depending on whether the event is required, and for whom.
		- parameter event: Same as the global variable, but not nil.
	*/
	private func configureFull(event:Event)
	{
		fullContainer.isHidden = !event.full
		fullDivider.isHidden = !event.full
	}
	/**
		Set up the map such that it displays the location of the event with a marker.
		- parameter event: Same as the global variable, but not nil.
	*/
	private func configureMap(event:Event)
	{
		mapMarker?.map = nil	//remove prev marker
		placesClient.lookUpPlaceID(event.placeId, callback: {
			result, error in
			guard result != nil else {
				return
			}
			
			self.placeLatLng = result?.coordinate
			self.map.moveCamera(GMSCameraUpdate.fit(result!.viewport!))
			self.mapMarker = GMSMarker(position: result!.coordinate)
			self.mapMarker!.map = self.map
			self.map.selectedMarker = self.mapMarker
		})
	}
	/**
		Handle user selection of map's direction button. Opens Apple Maps and starts navigation.
		- parameter sender: the the button clicked.
	*/
	@objc func onDirectionsButtonClick(_ sender: UIButton)
	{
		guard placeLatLng != nil else {
			print("Directions clicked, but place not found by Google")
			return
		}
		
		if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!))
		{
			let googleMapsUrl = URL(string: "comgooglemaps://center=?q=\(placeLatLng!.latitude),\(placeLatLng!.longitude)")!
			UIApplication.shared.open(googleMapsUrl, options: [:], completionHandler: nil)
		}
		else
		{
			let appleMapsUrl = URL(string: "http://maps.apple.com/?q=\(placeLatLng!.latitude),\(placeLatLng!.longitude)")!
			UIApplication.shared.open(appleMapsUrl, options: [:], completionHandler: nil)
		}
	}
	/**
		Handle user selection of event detail's more button. Expands event description.
		- parameter tapGestureRecognizer: the gesture recognizer of the more button.
	*/
	@objc func onMoreButtonClick(_ tabGestureRecognizer: UITapGestureRecognizer)
	{
		moreButton.isHidden = true
		moreButtonGradient.isHidden = true
		eventDescription.numberOfLines = 0
	}
	/**
		Handle user selection of the event's add button. Adds/Removes `event` from selected events accordingly.
		- parameter tapGestureRecognizer: the gesture recognizer of the add button.
	*/
	@objc func onAddButtonClick(_ tapGestureRecognizer: UITapGestureRecognizer)
	{
		let hudDisplayTime = 0.6
		
        if (UserData.selectedEventsContains(event!))
		{
            refreshButton(added: false)
            UserData.removeFromSelectedEvents(event!)
            LocalNotifications.removeNotification(for: event!.pk)
			HUD.flash(.labeledSuccess(title: nil, subtitle: "Removed"), delay: hudDisplayTime)
        }
		else
		{
            refreshButton(added: true)
            UserData.insertToSelectedEvents(event!)
			LocalNotifications.createNotification(for: event!)
			HUD.flash(.labeledSuccess(title: nil, subtitle: "Added"), delay: hudDisplayTime)
        }
        changed = true
    }
    /**
		Change the `addButton` based on whether the event is selected.
		- parameter added: Whether or not this event is selected.
	*/
    private func refreshButton(added: Bool)
	{
		addButton.text = added ? "Remove" : "Add"
    }
}
