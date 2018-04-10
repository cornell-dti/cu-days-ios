//
//  InitialSettingsVC.swift
//  CU Days
//
//  Created by David Chu on 2018/4/10.
//  Copyright © 2018年 Cornell DTI. All rights reserved.
//

import UIKit

class InitialSettingsVC:UIViewController
{
	var didLayout = false
	
	/**
	Creates a `InitialSettingsVC` with a navigation bar.
	- returns: NavigationController containing `InitialSettingsVC`.
	*/
	static func createWithNavBar() -> UINavigationController
	{
		let initialSettingsVC = InitialSettingsVC()
		let navController = UINavigationController(rootViewController: initialSettingsVC)
		navController.navigationBar.topItem?.title = "CU Days"
		return navController
	}
	
	override func viewWillLayoutSubviews()
	{
		super.viewWillLayoutSubviews()
		
		guard !didLayout else {
			return
		}
		didLayout = true
		
		view.backgroundColor = UIColor.white
		let container = createContainer()
		let text = createTitle("Welcome to Cornell Days!", in: container)
		
		let header1 = createHeader("Get There.", in: container)
		header1.autoPinEdge(.top, to: .bottom, of: text, withOffset: 42)
		let paragraph1 = createParagraph("Use your customized calendar to find events for your college.", in: container)
		paragraph1.autoPinEdge(.top, to: .bottom, of: header1, withOffset: 10)
		
		let header2 = createHeader("Explore.", in: container)
		header2.autoPinEdge(.top, to: .bottom, of: paragraph1, withOffset: Layout.MARGIN)
		let paragraph2 = createParagraph("Browse, search, and filter through Cornell Day events to add to your calendar.", in: container)
		paragraph2.autoPinEdge(.top, to: .bottom, of: header2, withOffset: 10)
		
		let header3 = createHeader("Stay Informed.", in: container)
		header3.autoPinEdge(.top, to: .bottom, of: paragraph2, withOffset: Layout.MARGIN)
		let paragraph3 = createParagraph("Go to the official website within Settings for other important information and resources.", in: container)
		paragraph3.autoPinEdge(.top, to: .bottom, of: header3, withOffset: 10)
		
		let startButton = createButton(with: "Get Started", textSize: 24)
		container.addSubview(startButton)
		startButton.autoPinEdge(.top, to: .bottom, of: paragraph3, withOffset: 42)
		startButton.autoPinEdge(toSuperviewEdge: .left)
		startButton.autoPinEdge(toSuperviewEdge: .right)
		startButton.autoPinEdge(toSuperviewEdge: .bottom)
	}
	/**
		Creates a `UIView` within the view of the given `UIViewController`
		- parameter vc: UIViewController
		- returns: Container (content view of scroll view)
	*/
	private func createContainer() -> UIView
	{
		let scrollView = UIScrollView.newAutoLayout()
		view.addSubview(scrollView)
		scrollView.autoPinEdgesToSuperviewEdges()
		
		let container = UIView.newAutoLayout()
		scrollView.addSubview(container)
		container.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 40, left: Layout.MARGIN, bottom: 40, right: Layout.MARGIN))
		container.autoMatch(.width, to: .width, of: view, withOffset: -Layout.MARGIN * 2)
		return container
	}
	/**
		Creates a `UILabel` with the style of a title containing the given text.
		The title's top, left, and right sides are pinned to the `container`.
		The label assumes it is the topmost child.
		- parameters:
			- title: label.text
			- container: label.superview
		- returns: Label
	*/
	private func createTitle(_ title:String, in container: UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.BOLD, size: 28)
		text.text = title
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		text.autoPinEdge(toSuperviewEdge: .top)
		return text
	}
	/**
		Creates a `UILabel` with the style of a header containing the given text.
		The header's left and right sides are pinned to the `container`.
		- parameters:
			- header: label.text
			- container: label.superview
		- returns: Label
	*/
	private func createHeader(_ header:String, in container:UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.BOLD, size: 18)
		text.text = header
		text.textColor = Colors.BRIGHT_RED
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		return text
	}
	/**
		Creates a `UILabel` with the style of a paragraph containing the given text.
		The label's left and right sides are pinned to the `container`.
		- parameters:
			- paragraph: label.text
			- container: label.superview
		-returns: Label
	*/
	private func createParagraph(_ paragraph:String, in container:UIView) -> UILabel
	{
		let text = UILabel.newAutoLayout()
		container.addSubview(text)
		text.font = UIFont(name: Font.MEDIUM, size: 16)
		text.text = paragraph
		text.numberOfLines = 0
		text.autoPinEdge(toSuperviewEdge: .left)
		text.autoPinEdge(toSuperviewEdge: .right)
		return text
	}
	/**
		Creates a button with the given text and font size, with a specific style
		and padding. Adds listeners for on-click events.
		- parameters:
			- text: Text in button.
			- textSize: Font size of text in button.
		- returns: Button, with on-click listener set to `onButtonClick()`
	*/
	private func createButton(with text:String, textSize:CGFloat) -> UILabel
	{
		let button = PaddedLabel.newAutoLayout()
		button.padding = UIEdgeInsets(top: textSize/2, left: 0, bottom: textSize/2, right: 0)
		button.layer.borderWidth = 2
		button.layer.borderColor = Colors.RED.cgColor
		button.layer.cornerRadius = 10
		button.layer.masksToBounds = true
		
		button.numberOfLines = 0
		button.text = text
		button.textColor = Colors.RED
		button.textAlignment = .center
		button.font = UIFont(name: Font.DEMIBOLD, size: textSize)
		
		button.isUserInteractionEnabled = true
		button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onButtonClick(_:))))
		return button
	}
	/**
		Handles button clicks. Opens the main app.
		- parameter gestureRecognizer: Contains the view that was clicked.
	*/
	@objc func onButtonClick(_ gestureRecognizer: UIGestureRecognizer)
	{
		present(TabBarVC(), animated: true, completion: nil)
	}
}
