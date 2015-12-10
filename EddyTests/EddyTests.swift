//
//  EddyTests.swift
//  EddyTests
//
//  Created by Arturo Falck on 12/9/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import XCTest
@testable import Eddy


// NOTES:
//
// 1. you can test classes that you marked EddyTests under Target Membership (in the File Inspector)
//
class EddyTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testCurrentCalculator_simple_sameDirection() {
		let calc = CurrentCalculator();
		let nav = NavigationData(
			groundVelocity: Velocity(headingDegrees: Heading.N.rawValue, speedInKnots: 5.0),
			waterVelocity: Velocity(headingDegrees: Heading.N.rawValue, speedInKnots: 4.0));
		let expectedResult = Velocity(headingDegrees: Heading.N.rawValue, speedInKnots: 1.0)
		let actualResult = calc.currentVelocityFromNavigationData(nav)
		
		XCTAssertEqual(expectedResult, actualResult);
	}
	
	func testCurrentCalculator_simple_perpendicularDirection() {
		let calc = CurrentCalculator();
		let nav = NavigationData(
			groundVelocity: Velocity(headingDegrees: Heading.N.rawValue, speedInKnots: sqrt(2)),
			waterVelocity: Velocity(headingDegrees: Heading.NE.rawValue, speedInKnots: 1.0));
		let expectedResult = Velocity(headingDegrees: Heading.NW.rawValue, speedInKnots: 1.0)
		let actualResult = calc.currentVelocityFromNavigationData(nav)
		
		XCTAssertEqual(expectedResult, actualResult);
	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
		}
	}
	
}
