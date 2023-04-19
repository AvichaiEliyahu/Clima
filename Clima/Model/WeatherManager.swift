//
//  WeatherManager.swift
//  Clima
//
//  Created by Avichai Eliyahu on 05/04/2023.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=9fda25345a986cb0a652facecfcee8ab&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func featchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with url: String){
        if let urlObj = URL(string: url){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: urlObj, completionHandler: handle)
            task.resume()
        }
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?) -> Void{
        if error != nil {
            delegate?.didFailWithError(error: error!)
            return
        }
        
        if let safeData = data{
            if let weather = parseJSON(weatherData: safeData){
                delegate?.didUpdateWeather(self, weather: weather)
            }
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let weather = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temprature: decodedData.main.temp)
            return weather
        } catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
