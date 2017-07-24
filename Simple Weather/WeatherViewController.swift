//
//  WeatherViewController.swift
//  Simple Weather
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Alex's Company. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureValueLabel: UILabel!
    @IBOutlet weak var cloudCoverValueLabel: UILabel!

    @IBOutlet weak var windValueLabel: UILabel!
    @IBOutlet weak var humidityValueLabel: UILabel!
    @IBOutlet weak var pressureValueLabel: UILabel!

    @IBOutlet weak var cityTextField: UITextField!{
        didSet{
            cityTextField.delegate = self
        }
    }

    let locationManager = CLLocationManager()
    var weatherGetter: WeatherGetter!
    var currentWeather: Weather?

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)

        getLocation()
    }

    @IBAction func getWeatherButtonTouch(_ sender: UIButton) {
        currentWeather = nil
        getLocation()
    }

    @IBAction func searchButtonTouch(_ sender: UIButton) {
        guard let text = cityTextField.text, !text.trimmed.isEmpty else {
            return
        }
        
        if let city = cityTextField.text?.trimmed, !city.isEmpty{
            currentWeather = nil
            weatherGetter.getWeatherByCity(city: cityTextField.text!.urlEncoded)
        }
    }
}

extension WeatherViewController: WeatherGetterDelegate {

    func didGetWeather(weather: Weather){
        DispatchQueue.main.async {
            if self.currentWeather == nil{
                self.cityLabel.text = weather.city
                self.weatherLabel.text = weather.weatherDescription
                self.temperatureValueLabel.text = "\(Int(round(weather.tempCelsius)))°"
                self.cloudCoverValueLabel.text = "\(weather.cloudCover)%"
                self.windValueLabel.text = "\(weather.windSpeed) m/s"
                self.humidityValueLabel.text = "\(weather.humidity)%"
                self.pressureValueLabel.text = "\(weather.pressure) hpa"

                self.addWeatherToHistory(weather)
                self.currentWeather = weather
            }
        }
    }

    func didNotGetWeather(error: Error){
        DispatchQueue.main.async {
            let alert = UIAlertController.simpleAlert(title: "Can't get the weather",
                                                      message: "The weather service isn't responding.")
            self.present(alert, animated: true, completion: nil)
        }
    }

    func addWeatherToHistory(_ weather: Weather){
        if let tabBarVC = self.tabBarController{
            let historyTableViewVC = (tabBarVC.viewControllers?[1] as! UINavigationController).viewControllers[0] as! HistoryTableViewController
            historyTableViewVC.addWeatherRequest(weather)
        }
    }

}

extension WeatherViewController: CLLocationManagerDelegate{

    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            let alert = UIAlertController.simpleAlert(title: "Please turn on location services",
                                                      message: "This app needs location services in order to report the weather " +
                                                        "for your current location.\n" +
                                                        "Go to Settings → Privacy → Location Services and turn location services on.")
            self.present(alert, animated: true, completion: nil)
            return
        }

        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                let alert = UIAlertController.simpleAlert(title: "Location services for this app are disabled",
                                                          message: "In order to get your current location, please open Settings for this app, choose \"Location\"  and set \"Allow location access\" to \"While Using the App\".")
                self.present(alert, animated: true, completion: nil)

                return

            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()

            default:
                print("Something wrong.")
            }

            return
        }

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        let lat = newLocation.coordinate.latitude
        let lon = newLocation.coordinate.longitude

        weatherGetter.getWeatherByCoordinates(latitude: lat, longitude: lon)

        self.latitudeLabel.text = "lat: \(String.init(format: "%.5f", lat))"
        self.longitudeLabel.text = "lon: \(String.init(format: "%.5f", lon))"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController.simpleAlert(title: "Can't determine your location",
                                                      message: "The GPS and other location services aren't responding.")
            self.present(alert, animated: true, completion: nil)
        }
        print("locationManager didFailWithError: \(error)")
    }
}

extension UIAlertController{

    static func simpleAlert(title: String, message: String)-> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style:  .default,
            handler: nil
        )

        alert.addAction(okAction)

        return alert
    }
}

extension WeatherViewController: UITextFieldDelegate{

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension String {

    // A handy method for %-encoding strings containing spaces and other
    // characters that need to be converted for use in URLs.
    var urlEncoded: String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlUserAllowed)!
    }

    var trimmed: String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
}


