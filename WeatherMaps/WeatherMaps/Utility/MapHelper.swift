//
//  MapHelper.swift
//  WeatherMaps
//
//  Created by Francesco Paciello on 17/04/23.
//

import Foundation
import CoreLocation
import MapKit

class MapHelper{
    
    // Given latitude, longitude and a delta, calculates a mapCoordinate region.
    static func calculateMapRegion(_ latitude : CLLocationDegrees, _ longitude : CLLocationDegrees, _ delta : CLLocationDegrees) -> MKCoordinateRegion {
        let span = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)

        let location = CLLocationCoordinate2DMake(latitude, longitude)

        let region = MKCoordinateRegion(center: location, span: span)
        
        return region
    }
    
}
