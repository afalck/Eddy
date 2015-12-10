//
//  CurrentCalculator.swift
//  Eddy
//
//
//  The top of this file also includes the Data structures
//
//  Created by Arturo Falck on 12/10/15.
//  Copyright © 2015 Arturo Falck. All rights reserved.
//

import Foundation

// I added these for convenience and to clarify the convention.
enum Heading : Float{
	case N = 0.0;
	case E = 90.0;
	case S = 180.0;
	case W = 270.0;
	
	case NE = 45.0;
	case SE = 135.0;
	case SW = 225.0;
	case NW = 315.0;
}

struct Velocity: CustomStringConvertible, Equatable{
	let headingDegrees: Float; //In Degrees 0 = True North; 90 = East; 180 = South; 270 = West (see Heading enum)
	let speedInKnots: Float;
	
	var headingRadians: Float {
		get { return headingDegrees.degreesToRadians }
	}
	
	var description: String {
		return "heading: \(headingDegrees) degrees, at: \(speedInKnots) knots"
	}
}

func ==(lhs: Velocity, rhs: Velocity) -> Bool
{
	let err = Float(0.0001);
	
	let lh = lhs.headingDegrees.normalizedDegrees;
	let rh = rhs.headingDegrees.normalizedDegrees;
	let ls = lhs.speedInKnots;
	let rs = rhs.speedInKnots;
	
	let returnValue = abs(ls - rs) < err && abs(lh - rh) < err
	return returnValue;
}

struct NavigationData: CustomStringConvertible {
	let groundVelocity: Velocity;
	let waterVelocity: Velocity;
	
	var description: String {
		return "ground: \(groundVelocity) -- water: \(waterVelocity)"
	}
	
}

class CurrentCalculator {
	
	//NOTE: sorry for the mixed metaphors here... feel free to refactor this code.
	func currentVelocityFromNavigationData(navigationData: NavigationData) -> Velocity{
		
		//NOTE: I am using the labels from the image Wind_drift.png (so tas=true air speed fills in for the magnitude of the water Velocity)
		let gs = navigationData.groundVelocity;
		let tas = navigationData.waterVelocity;
		
		// tas + w = gs
		// w = gs - tas
		
		let gsY = gs.speedInKnots * cos(gs.headingRadians); //North Component (this is counter-intuitive but remember that Nort = 0)
		let gsX = gs.speedInKnots * sin(gs.headingRadians); //East Component (also remember that heading is measured clockwise)
		
		let tasY = tas.speedInKnots * cos(tas.headingRadians);
		let tasX = tas.speedInKnots * sin(tas.headingRadians);
		
		let wY = gsY - tasY;
		let wX = gsX - tasX;
		
		let w = Velocity(headingDegrees: atan2(wX, wY).radiansToDegrees, speedInKnots: sqrt(pow(wY,2) + pow(wX,2)));
		
		return w;
	}
}

extension Float {
	var degreesToRadians : Float {
		return self * Float(M_PI) / 180.0
	}
	var radiansToDegrees : Float {
		return self * 180.0 / Float(M_PI)
	}
	var normalizedDegrees : Float {
		let fullCircle = Float(360);

		let lastFractionOfCicle = self % fullCircle;
		let guaranteePositive = lastFractionOfCicle + fullCircle;
		let lastFractionOfPositiveCircle = guaranteePositive % fullCircle;
		
		return lastFractionOfPositiveCircle;
	}
}