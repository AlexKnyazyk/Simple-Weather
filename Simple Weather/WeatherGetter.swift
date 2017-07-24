//
//  WeatherGetter.swift
//  Simple Weather
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Alex's Company. All rights reserved.
//

import Foundation

protocol WeatherGetterDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: Error)
}


class WeatherGetter {

    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "17472cf82a3c63c1a14e2d9ea6305a3c"

    private var delegate: WeatherGetterDelegate


    // MARK: -

    init(delegate: WeatherGetterDelegate) {
        self.delegate = delegate
    }

    func getWeatherByCity(city: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL)
    }

    func getWeatherByCoordinates(latitude: Double, longitude: Double) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(latitude)&lon=\(longitude)")!
        getWeather(weatherRequestURL)
    }

    private func getWeather(_ weatherRequestURL: NSURL) {
        // This is a pretty simple networking task, so the shared session will do.
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 1

        // The data task retrieves the data.

        let dataTask = session.dataTask(with: weatherRequestURL as URL) {
            (data, response, error) in
            if let networkError = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetWeather(error: networkError)
            }
            else {
                // Case 2: Success
                // We got data from the server!
                do {
                    // Try to convert that data i/Users/admin/Desktop/Projects/Simple Weather/Simple Weather/WeatherGetter.swiftnto a Swift dictionary
                    let weatherData = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]

                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Let's now used that dictionary to initialize a Weather struct.
                    if weatherData.keys.count > 3{
                        let weather = Weather(weatherData: weatherData)
                        self.delegate.didGetWeather(weather: weather)
                    }
                }
                catch let jsonError{
                    self.delegate.didNotGetWeather(error: jsonError)
                }
            }
        }

        dataTask.resume()
    }
    
}
