//
//  APIController.swift
//  UpcomingMovies
//
//  Created by Patrick Haralabidis on 2/02/2016.
//  Copyright © 2016 Patrick Haralabidis. All rights reserved.
//

import Foundation

protocol APIControllerDelegate {
    func apiSucceededWithResults(_ results: NSArray)
    func apiFailedWithError(_ error: String)
}

class APIController: NSObject {
    
    var delegate:APIControllerDelegate?
    
    func getAPIResults(_ urlString:String) {
        
        //The Url that will be called.
        let url = URL(string: urlString)
        //Create a request.
        let request = URLRequest(url:url!)
        //Sending Asynchronous request using NSURLSession.
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                //Check that we have received data
                guard let data = data else {
                    self.delegate?.apiFailedWithError("ERROR: no data")
                    return
                }
                //Call the JSON serialisation methdod to generate array of results.
                self.generateResults(data)
            }
        }) .resume()
    }
    
    func generateResults(_ apiData: Data)
    {
        do {
            //Serialise the api data into a json object
            let jsonResult = try JSONSerialization.jsonObject(with: apiData, options: .allowFragments)
            //verify we can serialise the json object into a dictionary
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else {
                self.delegate?.apiFailedWithError("ERROR: conversion from JSON failed")
                return
            }
            //Create an array of results
            let results: NSArray = jsonDictionary["results"] as! NSArray
            //Use the completion handler to pass the results
            self.delegate?.apiSucceededWithResults(results)
        }
        catch {
            self.delegate?.apiFailedWithError("ERROR: conversion from JSON failed")
        }
    }
    
}
