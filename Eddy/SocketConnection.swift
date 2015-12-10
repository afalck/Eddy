//
//  SocketConnection.swift
//  Eddy
//
//  Created by Arturo Falck on 12/9/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import Foundation

public class SocketConnection : NSObject, NSStreamDelegate{
	
	let bufferSize = 1024;
	let encoding = UInt(1);
	
	var inputStream: NSInputStream?
//	var outputStream: NSWriteStream?
	
	var host: String;
	var port: UInt32;
	var status: Bool;
	var output: String;
	
	init(host: String, port:UInt32){
		self.host = host
		self.port = port
		self.status = false
		output = ""
//		super.init()
	}
	

	public func stream(aStream: NSStream, handleEvent aStreamEvent: NSStreamEvent) {
		switch aStreamEvent {
			
		case NSStreamEvent.OpenCompleted:
			break
			
		case NSStreamEvent.HasBytesAvailable:
			
			break
			
		case NSStreamEvent.HasSpaceAvailable:
			break
			
		case NSStreamEvent.EndEncountered:
			
			//            aStream.close()
			aStream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
			break
			
		case NSStreamEvent.None:
			
			break
			
		case NSStreamEvent.ErrorOccurred:
			
			break
			
		default:
			NSLog("# something weird happend")
			break
		}
	}
	
	func connect() {
		NSLog("# connecting to \(host):\(port)")
		var cfReadStream : Unmanaged<CFReadStream>?
		var cfWriteStream : Unmanaged<CFWriteStream>?
		
		CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &cfReadStream, &cfWriteStream)
		inputStream = cfReadStream!.takeRetainedValue()
//		outputStream = cfWriteStream!.takeRetainedValue()
		
		inputStream!.delegate = self
	//	outputStream!.delegate = self
		
		inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
//		outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		
		inputStream!.open()
//		outputStream!.open()
	}
	
	
	func read() -> String{
		while (true){
			var buffer = [UInt8](count: bufferSize, repeatedValue: 0)
			output = ""
			while (self.inputStream!.hasBytesAvailable){
				var bytesRead: Int = self.inputStream!.read(&buffer, maxLength: buffer.count)
				if bytesRead >= 0 {
					output += NSString(bytes: UnsafePointer(buffer), length: bytesRead, encoding: encoding)! as String
				} else {
					NSLog("# error")
				}
				return output
			}
			//NSLog(".")
			usleep(100000)
		}
	}
	
//	func send(message:String){
//		let data:NSData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//		let bytesWritten = self.outputStream!.write(UnsafePointer(data.bytes), maxLength: data.length)
//		NSLog("< send to \(host)")
//		
//	}
}