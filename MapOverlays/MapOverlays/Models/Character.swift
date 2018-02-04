//
//  Character.swift
//  Park View
//
//  Created by GEORGE QUENTIN on 03/02/2018.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import MapKit

public class Character: MKCircle {
    
    var name: String?
    var color: UIColor?
    
    convenience public init(filename: String, color: UIColor) {
        guard let points = Park.plist(filename) as? [String] else { self.init(); return }
        
        let cgPoints = points.map { CGPointFromString($0) }
        let coords = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
        
        let randomCenter = coords[Int(arc4random()%4)]
        let randomRadius = CLLocationDistance(max(5, Int(arc4random()%40)))
        
        self.init(center: randomCenter, radius: randomRadius)
        self.name = filename
        self.color = color
    }
}
