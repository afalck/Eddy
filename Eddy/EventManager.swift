//
//  EventManager.swift
//  Updated for Swift 2.0 with Xcode 7.1
//
//  Copyright (c) 2015 Arturo Falck
//

import Foundation

class EventManager<T> {
	var listeners = Array<T>();
	
	func listenTo(listener: T){
		listeners.append(listener);
	}
	
	func trigger(action: (listener: T) -> ()) {
		for l in listeners{
			action(listener: l);
		}
	}
}
