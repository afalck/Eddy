//
//  ViewController.swift
//  Eddy
//
//  Created by Arturo Falck on 12/9/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import UIKit
import Foundation



class ViewController: UIViewController, NavigationListener {
	
	let calc = CurrentCalculator();
	
	@IBOutlet var rawFeed: UILabel!
	@IBOutlet var currentVelText: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		start();
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	func start(){
		var socketConnection = SocketConnection(host: "localhost", port: 5001);
		
		let reader = Reader(socketConnection: socketConnection);
		reader.addListener(self);
		
		reader.start();
	}
	
	func receivedNavigationData(navigationData: NavigationData){
		NSLog("\(navigationData)");
		let currentVelocity = calc.currentVelocityFromNavigationData(navigationData);
		
		rawFeed.text = "\(navigationData)"
		currentVelText.text = "\(currentVelocity)"
	}
	
	
}

