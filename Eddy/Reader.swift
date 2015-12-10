//
//  Reader.swift
//  Eddy
//
//  This little class just manages the SocketConnection on its own thread and uses callbacks to notify its listeners
//  when we receive new data.
//
//  The top of this file also includes the callback protocol
//
//  Created by Arturo Falck on 12/10/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import Foundation
import UIKit


// Implement this protocol to receive updates on the callback method.
protocol NavigationListener {
	
	// the callback method.  I call this from the UI thread so don't do long calculations here or the UI will become unresponsive.
	func receivedNavigationData(navigationData: NavigationData);
}


// helper class that manages the reading thread.
class Reader {
	let navEvents = EventManager<NavigationListener>();
	let socketConnection: SocketConnection;
	
	init (socketConnection: SocketConnection){
		self.socketConnection = socketConnection;
	}
	
	func addListener(listener: NavigationListener){
		navEvents.listenTo(listener);
	}
	
	func start(){
		socketConnection.connect();
		waitAndRead();
	}
	
	// NOTE: this is a common multi-threading idiom in swift:
	// you dispatch a call asynchronously and then have that call dispatch the reporting in the main thread.
	//
	//
	// normally this is done once... for example: "go load an image from a server... when you are done display it in the GUI".
	// but I am using it here to continuously do something in the background by having it restart the process when done.
	// notice that it uses recursion instead of iteration because swift expects these closures to be fairly short lived.
	//
	// Closure: notice the {() -> Void in ...} sections.  Those are closures, which is essentially an annonymous function.
	// Swift 2 uses them often... it is worth learning about them.
	private func waitAndRead(){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			let line = self.socketConnection.read();
			let rawData = line.componentsSeparatedByString(" ");
			
			//NOTE: this makes the callback come in the UI thread
			dispatch_sync(dispatch_get_main_queue(), { () -> Void in
				self.received(rawData);
			})
			
			self.waitAndRead();
		})
	}
	
	private func received(rawData: [String]){
		
		if (rawData.count != 4){
			NSLog("Incomplete or extra data: \(rawData)")
			return;
		}

		let groundHeading = (rawData[0] as NSString).floatValue;
		let groundSpeed = (rawData[1] as NSString).floatValue;
		let waterHeading = (rawData[2] as NSString).floatValue;
		let waterSpeed = (rawData[3] as NSString).floatValue;
		
		let gv = Velocity(headingDegrees: groundHeading, speedInKnots: groundSpeed)
		let wv = Velocity(headingDegrees: waterHeading, speedInKnots: waterSpeed)
		let data = NavigationData(groundVelocity: gv, waterVelocity: wv)
		
		self.navEvents.trigger{
			(listener: NavigationListener) -> () in listener.receivedNavigationData(data);
		}
	}
}
