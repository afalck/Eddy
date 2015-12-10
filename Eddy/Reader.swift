//
//  Reader.swift
//  Eddy
//
//  This little class just manages the SocketConnection on its own thread and uses callbacks to notify its listeners
//  when we receive new data.
//
//  The top of this file also includes the Data structures and callback protocol
//
//  Created by Arturo Falck on 12/10/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import Foundation
import UIKit


struct NavigationData: CustomStringConvertible {
	let groundVelocity: Velocity;
	let waterVelocity: Velocity;
	
	var description: String {
		return "ground: \(groundVelocity) water: \(waterVelocity)"
	}

}

struct Velocity: CustomStringConvertible{
	let heading: Float;
	let speedInKnots: Float;
	
	var description: String {
		return "heading: \(heading) degrees.  speed: \(speedInKnots) knots"
	}

}

// Implement this protocol to receive updates on the callback method.
protocol NavigationListener {
	// the callback method.
	func receivedNavigationData(navigationData: NavigationData);
}

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
	
	private func waitAndRead(){
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			let line = self.socketConnection.read();
			let rawData = line.componentsSeparatedByString(" ");
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
		
		let gv = Velocity(heading: groundHeading, speedInKnots: groundSpeed)
		let wv = Velocity(heading: waterHeading, speedInKnots: waterSpeed)
		let data = NavigationData(groundVelocity: gv, waterVelocity: wv)
		
		self.navEvents.trigger{
			(listener: NavigationListener) -> () in listener.receivedNavigationData(data);
		}
	}
}
