//
//  APIController.swift
//  UpcomingMovies
//
//  Created by Patrick Haralabidis on 2/02/2016.
//  Copyright © 2016 Patrick Haralabidis. All rights reserved.
//

import Foundation

enum JSONError: String, ErrorType {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
}


protocol APIControllerDelegate {
    func apiSucceededWithResults(results: NSArray)
    func apiFailedWithError(error: String)
}

class APIController: NSObject {
    
    var delegate:APIControllerDelegate?
    
    func getAPIResults(urlString:String) {
        
        //The Url that will be called.
        let url = NSURL(string: urlString)
        //Create a request.
        let request = NSMutableURLRequest(URL:url!)
        //Sending Asynchronous request using NSURLSession.
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                //Check that we have received data
                guard let data = data else {
                    self.delegate?.apiFailedWithError(JSONError.NoData.rawValue)
                    return
                }
                //Call the JSON serialisation methdod to generate array of results.
                self.generateResults(data)
            }
        }.resume()
    }
    
    func generateResults(apiData: NSData)
    {
        do {
            //Serialise the api data into a json object
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(apiData, options: .AllowFragments)
            //verify we can serialise the json object into a dictionary
            guard let jsonDictionary: NSDictionary = jsonResult as? NSDictionary else {
                self.delegate?.apiFailedWithError(JSONError.ConversionFailed.rawValue)
                return
            }
            //Create an array of results
            let results: NSArray = jsonDictionary["results"] as! NSArray
            //Use the completion handler to pass the results
            self.delegate?.apiSucceededWithResults(results)
        }
        catch {
            self.delegate?.apiFailedWithError(JSONError.ConversionFailed.rawValue)
        }
    }
    
}
