//
//  ViewController.swift
//  WeatherMaps
//
//  Created by Francesco Paciello on 15/04/2023.
//

import UIKit
import CoreLocation
import MapKit

class WeatherViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var degreesText: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var celsiusLabel: UILabel!
    @IBOutlet weak var localizationButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    // WeatherManager reference.
    var weatherManager = WeatherManager()
    
    // Location manager reference.
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the viewcontroller as the delegate.
        locationManager.delegate = self
        
        // Request authorization for gps usage.
        locationManager.requestWhenInUseAuthorization()
        
        // Request gps location.
        locationManager.requestLocation()
        
        // Start gps update.
        locationManager.startUpdatingLocation()
        
        // Update the ui based on the current system time.
        updateUIOnTimeChange()
        
        // Assigning the tap gestor to respond within this controller.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.handleTapGesture(gestureRecognizer:)))
        
        // Adding the gesture recognizer to the mapview.
        self.mapView.addGestureRecognizer(tapGesture)
        
        // Setting the viewcontroller as the delegate.
        mapView.delegate = self
        weatherManager.delegate = self
        searchBar.delegate = self
    }
    
    // Function used to manage the tap gesture on map.
    @objc func handleTapGesture(gestureRecognizer: UITapGestureRecognizer){
        
        // I recognize the state of the gesture.
        if gestureRecognizer.state != UIGestureRecognizer.State.began{
            
            // Getting the touch location from the map.
            let touchLocation = gestureRecognizer.location(in: mapView)
            
            // Converting the tap location in WGS-84 coordinates
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            // Fetching the current weather at the corrisponding coordinates.
            weatherManager.fetchWeather(lat: locationCoordinate.latitude, lon: locationCoordinate.longitude)
        }
    }

    // Requests a location update.
    @IBAction func locationRequested(_ sender: UIButton) {
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    // Updates the UI elements based on the current system time.
    func updateUIOnTimeChange() {
        // Fetch the current date.
        let date = Date()
        let calendar = Calendar.current
        
        // Gett the current hour.
        let hour = calendar.component(.hour, from: date)
        _ = calendar.component(.minute, from: date)
        
        let dayImage = UIImage(named:"Day")
        let nightImage = UIImage(named:"Night")
        
        // Checking if it's day or night
        if hour < 6 || hour > 18  {
            UIView.transition(with: timeImageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.timeImageView.image = nightImage },
                              completion: nil)
            locationLabel.textColor = .white
            celsiusLabel.textColor = .white
            weatherImage.tintColor = .white
            degreesText.textColor = .white
            localizationButton.tintColor = .white
        }else {
            UIView.transition(with: timeImageView,
                              duration: 0.75,
                              options: .transitionCrossDissolve,
                              animations: { self.timeImageView.image = dayImage },
                              completion: nil)
            
            let constartColor = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1)
            
            locationLabel.textColor = constartColor
            celsiusLabel.textColor = constartColor
            weatherImage.tintColor = constartColor
            degreesText.textColor = constartColor
            localizationButton.tintColor = constartColor
        }
    }
}

//MARK: - UISearchBarDelegate
extension WeatherViewController : UISearchBarDelegate {
    
    // Function called when the keybord input should end
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if searchBar.text != "" {
            return true
        }else{
            searchBar.placeholder = "Enter a city name!"
            return true
        }
    }
    
    // Function called when the keyobard endend it's input.
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Checking with safe check the input on the search bar.
        if let city = searchBar.text{
            // Fetching the weather of the input city.
            weatherManager.fetchWeather(cityName: city)
        }
        // Resetting the search bar text field.
        searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController : WeatherManagerDelegate{
    
    // Function responding to the weahter update coming from WeatherManager.
    func didUpdateWeather(_ weatherManager: WeatherManager ,weather: WeatherModel) {
        DispatchQueue.main.async{
            self.degreesText.text = weather.temperatureString
            self.weatherImage.image = UIImage(systemName: weather.conditionName)
            self.locationLabel.text = weather.cityName
            
            // Obtaining the longitude and latitude from the weather object.
            let latitude = CLLocationDegrees(weather.lat)
            let longitude = CLLocationDegrees(weather.lon)
            
            // Creating a Pin for the map view.
            let pin = MKPointAnnotation()
            pin.title = weather.cityName
            
            // Setting the pin coordinates.
            pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let allAnnotations = self.mapView.annotations
            
            // Removing the previous annotations.
            self.mapView.removeAnnotations(allAnnotations)
            
            // Adding the new annotation.
            self.mapView.addAnnotation(pin)
            
            // Calculating the region of the map to zoom in.
            let region = MapHelper.calculateMapRegion(latitude, longitude, 0.5)

            // Zoom on the current lat/lon location.
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    // Handles the failure of the fetching weather function.
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLLocationManagerDelegate
extension WeatherViewController : CLLocationManagerDelegate {
    
    // Responds to the gps location update.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Getting the last location update.
        if let location = locations.last {
            
            // Stop updating the gps location.
            locationManager.stopUpdatingLocation()
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // Fetch the weather based on the current latitude and longitude.
            weatherManager.fetchWeather(lat: latitude, lon: longitude)
            
            // Calculating the region of the map to zoom in.
            let region = MapHelper.calculateMapRegion(latitude, longitude, 0.5)

            // Zoom on the current lat/lon location.
            mapView.setRegion(region, animated: true)
        }
    }
    
    // Handles the failure of the fetching location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
