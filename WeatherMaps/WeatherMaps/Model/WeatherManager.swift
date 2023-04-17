//
//  WeatherManager.swift
//  WeatherMaps
//
//  Created by Francesco Paciello on 15/04/2023.
//

import Foundation
import CoreLocation

// Protocol declaration to handle the weather update.
protocol WeatherManagerDelegate{
    
    // A new weather is found.
    func didUpdateWeather(_ weatherManager: WeatherManager ,weather: WeatherModel)
    
    // An error occurred during the weather fetch.
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    // OpenWeatherMap API url.
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=970c633e0893dfac7a1d23bd2260e737&units=metric"
    
    // Reference on the weather manager delegate.
    var delegate: WeatherManagerDelegate?
    
    // Function to fetch a weather based on a city name passed as parameter.
    func fetchWeather(cityName : String){
        
        // API url composition.
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    // Function to fetch a weather based on a lat/lon passed as parameter.
    func fetchWeather(lat: CLLocationDegrees, lon: CLLocationDegrees){
        
        // API url composition.
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    // Performs the web request to fetch the weather.
    func performRequest(with urlString : String){
        
        // Safe check on webreq url.
        if let url = URL(string: urlString){
            
            // Creating a new web session.
            let session = URLSession(configuration: .default)
            
            // Creating a new task to perform the web request.
            let task = session.dataTask(with: url){ (data,response,error) in
                
                // An error occurred, the error protocol is called.
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                // No error occurred.
                if let safeData = data {
                    
                    // Safe check and parse of the weatherdata received.
                    if let weather = self.parseWeatherJSON(safeData){
                        
                        // Weatherupdate protocol called.s
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // Resuming / Starting the current task.
            task.resume()
        }
    }
    
    // Function to parse data coming from a JSON of type WeatherModel.
    func parseWeatherJSON(_ weatherData: Data) -> WeatherModel? {
        
        // Creating the decoder.
        let decoder = JSONDecoder()
        do{
            
            // Decoding the data received.
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let lat = decodedData.coord.lat
            let lon = decodedData.coord.lon
            
            // Creating a new WeatherModel object.
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, lat: lat, lon: lon)
            
            return weather
        } catch{
            
            // An error occurred, error protocol called.s
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
