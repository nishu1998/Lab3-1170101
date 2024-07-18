//
//  CitiesViewController.swift
//  Lab3-1170101
//
//  Created by Nishant Gautam on 2024-07-17.
//

import UIKit

class CitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var weatherData: [WeatherData] = [] // Array to store weather data for each city
    var weatherIcon: UIImage?
    var weatherIconData: [(image: UIImage?, color: UIColor)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CityTableViewCell", bundle: nil), forCellReuseIdentifier: "CityCell")
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityTableViewCell
        
        let data = weatherData[indexPath.row]
        cell.cityNameLabel.text = "\(data.location.name)"
        let isFahrenheit = UserDefaults.standard.bool(forKey: "isFahrenheit")
        let temperatureInCelsius = data.current.temp_c
        let displayedTemperature = isFahrenheit ? (temperatureInCelsius * 9/5) + 32 : temperatureInCelsius
        cell.temperatureLabel.text = "\(displayedTemperature) \(isFahrenheit ? "°F" : "°C")"
        
        // Set weather condition icon and its color
        let iconData = weatherIconData[indexPath.row]
        cell.weatherIconImageView.image = iconData.image
        cell.weatherIconImageView.tintColor = iconData.color
        
        return cell
    }

}
