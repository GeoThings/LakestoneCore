//
//  Utilities.swift
//  geoCore
//
//  Created by Taras Vozniuk on 4/27/16.
//  Copyright © 2016 GeoThings. All rights reserved.
//

#if COOPER
import java.lang
#else
import Darwin.C
#endif

//to silence Cannot Convert return expression of type 'TileID?' to 'Self?'
internal func _safeObjectSelfCast<T>(obj: AnyObject?) -> T?   { return obj as? T }

/*
#if !COOPER
//matching COOPER definitions can be found in Swift.Shared/Functions.swift
public func stride(from start: Double, to end: Double, by stride: Double) -> StrideTo<Double> {
	return start.stride(to: end, by: stride)
}

public func stride(from start: Double, through end: Double, by stride: Double) -> StrideThrough<Double> {
	return start.stride(through: end, by: stride)
}
#endif
*/
 
/*
public func BoundingBoxesCroppedFromBoundingBox(boundingBox boundingBox: BoundingBox, cropValue: UInt) -> [BoundingBox] {
	
	//the length of initial bounding box
	let longInitialLength = boundingBox.ur.x - boundingBox.ll.x
	let latiInitialLength = boundingBox.ur.y - boundingBox.ll.y
	
	//the length of each element of croped bounding boxes
	let longTargetLength = longInitialLength / Double(cropValue)
	let latiTargetLength = latiInitialLength / Double(cropValue)
	
	let longStart = boundingBox.ll.x
	let latiStart = boundingBox.ll.y
	let longEnd = boundingBox.ur.x
	let latiEnd = boundingBox.ur.y
	
	var cropedBoundingBoxes = [BoundingBox]()
	
	for longIndex in stride(from: longStart, to: longEnd, by: longTargetLength){
		for latiIndex in stride(from: latiStart, to: latiEnd, by: latiTargetLength){
			let newBox = BoundingBox(ll: Coordinate(x: longIndex, y: latiIndex), ur:Coordinate(x: longIndex + longTargetLength, y: latiIndex + latiTargetLength))
			cropedBoundingBoxes.append(newBox)
		}
	}
	
	return cropedBoundingBoxes
}
*/

/*
#if COOPER
private let _radianDegreeMultiplier = 180/Math.PI
#else
private let _radianDegreeMultiplier = 180/M_PI
#endif

public func sphericalMercatorLatitudeProjection(latitude: Double) -> Double {
	#if COOPER
	return Math.atan(Math.sinh(latitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
	#else
	return atan(sinh(latitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
	#endif
}

public func localLatitudeFromSpericalMercatorProjection(latitude: Double) -> Double {
	
	var safeLatitude: Double
	
	// Spherical mercator project latitude gets bounded within [-85.0511287798066, 85.0511287798066]
	// if latitude passed is outside of these bounds -> use bound values instead
	safeLatitude = (latitude < -SphericalMercatorPoleLimit) ? -SphericalMercatorPoleLimit : latitude
	safeLatitude = (safeLatitude > SphericalMercatorPoleLimit) ? SphericalMercatorPoleLimit : safeLatitude
	
	#if COOPER
	return Math.log((1.0+Math.sin(safeLatitude/_radianDegreeMultiplier))/Math.cos(safeLatitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
	#else
	return log((1.0+sin(safeLatitude/_radianDegreeMultiplier))/cos(safeLatitude/_radianDegreeMultiplier)) * _radianDegreeMultiplier
	#endif
}

/** The most northest point achievable in spherical mercator coordinate system(85.0511287798066) */
public var SphericalMercatorPoleLimit: Double { return sphericalMercatorLatitudeProjection(latitude: 180.0) }

#if COOPER
public func abs(_ value: Int) -> Int {
	return Math.abs(value)
}
#endif
*/
