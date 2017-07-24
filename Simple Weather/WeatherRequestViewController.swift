//
//  WeatherRequestViewController.swift
//  Simple Weather
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Alex's Company. All rights reserved.
//

import UIKit

class WeatherRequestViewController: UIViewController {

    var city: String?
    var weatherGetter: WeatherGetter!

    @IBOutlet weak var lattitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!

    @IBOutlet weak var temperatureValueLabel: UILabel!
    @IBOutlet weak var cloudCoverValueLabel: UILabel!
    @IBOutlet weak var windValueLabel: UILabel!
    @IBOutlet weak var humidityValueLabel: UILabel!
    @IBOutlet weak var pressureValueLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        weatherGetter = WeatherGetter(delegate: self)

        if city != nil{
            weatherGetter.getWeatherByCity(city: city!)
        }
    }
}

extension WeatherRequestViewController: WeatherGetterDelegate{

    func didGetWeather(weather: Weather){
        DispatchQueue.main.async {
            self.lattitudeLabel.text = "lat: \(weather.latitude)"
            self.longitudeLabel.text = "lon: \(weather.longitude)"
            self.cityLabel.text = weather.city
            self.weatherLabel.text = weather.weatherDescription
            self.temperatureValueLabel.text = "\(Int(round(weather.tempCelsius)))°"
            self.cloudCoverValueLabel.text = "\(weather.cloudCover)%"
            self.windValueLabel.text = "\(weather.windSpeed) m/s"
            self.humidityValueLabel.text = "\(weather.humidity)%"
            self.pressureValueLabel.text = "\(weather.pressure) hpa"
        }
    }


    func didNotGetWeather(error: Error){
        DispatchQueue.main.async {
            let alert = UIAlertController.simpleAlert(title: "Can't get the weather",
                                                      message: "The weather service isn't responding.")
            self.present(alert, animated: true, completion: nil)
        }
    }
}
