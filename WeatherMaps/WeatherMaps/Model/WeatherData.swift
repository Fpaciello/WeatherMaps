//
//  WeatherData.swift
//  WeatherMaps
//
//  Created by Francesco Paciello on 15/04/2023.
//

import Foundation

struct WeatherData : Decodable {
    let name: String
    
    let main: Main
    
    let weather : [Weather]
    
    let coord : Coord
}

struct Coord: Decodable{
    let lon : Double
    let lat : Double
}

struct Main: Decodable{
    let temp: Double
}

struct Weather: Decodable{
    let id: Int
    let description: String
}



