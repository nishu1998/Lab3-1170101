//
//  ViewController.swift
//  Lab3-1170101
//
//  Created by Nishant Gautam on 2024-07-17.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var tempratureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var cities: UIButton!
    
    @IBOutlet weak var weatherCondition: UILabel!
    
    @IBOutlet weak var celsius: UIButton!
    
    @IBOutlet weak var fahrenheit: UIButton!
    
    let locationManager = CLLocationManager()
    var currentWeatherData: WeatherData?
    var citiesWeatherData: [WeatherData] = []
    var weatherIconData: [(image: UIImage?, color: UIColor)] = []

    
    
    override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            updateToggleButtons(isFahrenheit: UserDefaults.standard.bool(forKey: "isFahrenheit"))
        }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestLocation()
       
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        guard let location = searchTextField.text, !location.isEmpty else {
                    return}
        fetchWeatherData(for: location)
    }
    
    @IBAction func showCitiesWeather(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
           guard let citiesVC = storyboard.instantiateViewController(withIdentifier: "CitiesViewController") as? CitiesViewController else { return }
           citiesVC.weatherData = citiesWeatherData
           citiesVC.weatherIconData = weatherIconData // Pass the icon data here
           navigationController?.pushViewController(citiesVC, animated: true)
       }
    
    
    func fetchWeatherData(for location: String) {
        let apiKey = "4fa3181643324e45ae801240241803"
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(location)&aqi=no"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                self.currentWeatherData = weatherData
                self.citiesWeatherData.append(weatherData)
                
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func updateUI(with weatherData: WeatherData) {
        locationLabel.text = "\(weatherData.location.name), \(weatherData.location.country)"
        weatherCondition.text = weatherData.current.condition.text
        updateTemperatureDisplay()
        
        let temperature = weatherData.current.temp_c
        var image: UIImage?
        var color: UIColor
        
        if temperature < 10 {
            image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysTemplate)
            color = UIColor.blue
        } else if temperature >= 10 && temperature <= 35 {
            image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysTemplate)
            color = UIColor.yellow
        } else {
            image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysTemplate)
            color = UIColor.red
        }
        
        weatherImage.image = image
        weatherImage.tintColor = color
        weatherIconData.append((image: image, color: color))
    }

    
    
    
    @IBAction func fahrenheitButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isFahrenheit")
                updateToggleButtons(isFahrenheit: true)
                updateTemperatureDisplay()
       }
       
       @IBAction func celsiusButtonTapped(_ sender: UIButton) {
           UserDefaults.standard.set(false, forKey: "isFahrenheit")
                   updateToggleButtons(isFahrenheit: false)
                   updateTemperatureDisplay()
       }
    
    func updateToggleButtons(isFahrenheit: Bool) {
           fahrenheit.backgroundColor = isFahrenheit ? UIColor.systemBlue : UIColor.clear
           fahrenheit.setTitleColor(isFahrenheit ? UIColor.white : UIColor.systemBlue, for: .normal)
           
           celsius.backgroundColor = isFahrenheit ? UIColor.clear : UIColor.systemBlue
           celsius.setTitleColor(isFahrenheit ? UIColor.systemBlue : UIColor.white, for: .normal)
       }
    
    func updateTemperatureDisplay() {
           guard let weatherData = currentWeatherData else { return }
           
           let isFahrenheit = UserDefaults.standard.bool(forKey: "isFahrenheit")
           let temperatureInCelsius = weatherData.current.temp_c
           let displayedTemperature: Double
           
           if (isFahrenheit) {
               displayedTemperature = (temperatureInCelsius * 9/5) + 32
               tempratureLabel.text = "\(displayedTemperature) °F"
           } else {
               displayedTemperature = temperatureInCelsius
               tempratureLabel.text = "\(displayedTemperature) °C"
           }
       }
    
    // CLLocationManagerDelegate methods
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                fetchWeatherData(for: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get user's location: \(error.localizedDescription)")
        }
    }

struct WeatherData: Codable {
    struct Location: Codable {
        let name: String
        let country: String
    }
    
    struct Current: Codable {
        struct Condition: Codable {
            let text: String
        }
        let temp_c: Double
        let condition: Condition
    }
    
    let location: Location
    let current: Current
}
