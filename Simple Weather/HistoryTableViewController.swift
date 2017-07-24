//
//  HistoryTableViewController.swift
//  Simple Weather
//
//  Created by Admin on 24.07.17.
//  Copyright © 2017 Alex's Company. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var weatherRequests: [Weather] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return weatherRequests.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! WeatherTableViewCell

        // Configure the cell...
        let weather = weatherRequests[indexPath.row]
        cell.cityLabel.text = weather.city

        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        cell.dateLabel.text = formatter.string(from: weather.dateAndTime as Date)

        cell.locationLabel.text = "lat: \(weather.latitude) lon: \(weather.longitude)"
        return cell
    }

    func addWeatherRequest(_ weather: Weather){
        self.weatherRequests.insert(weather, at: 0)
        self.tableView.reloadData()
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weatherRequestSegue" {
            if let weatherRequestVC = segue.destination as? WeatherRequestViewController{
                weatherRequestVC.city = weatherRequests[(tableView.indexPathForSelectedRow?.row)!].city
            }
        }
    }


}
