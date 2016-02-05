//
//  ViewController.swift
//  UpcomingMovies
//
//  Created by Patrick Haralabidis on 2/02/2016.
//  Copyright © 2016 Patrick Haralabidis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, APIControllerDelegate {

    @IBOutlet weak var appTableView: UITableView!
    
    var searchResultsData: NSArray = []
    var api: APIController = APIController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUpcomingMovies()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "MovieResultsCell"
        
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell
        
        //Create a variable that will contain the result data array item for each row
        let cellData: NSDictionary = self.searchResultsData[indexPath.row] as! NSDictionary
        //Assign and display the Title field
        cell.textLabel!.text = cellData["title"] as? String
        
        // Construct the posterUrl to get an image URL for the movie thumbnail
        let imgURL: NSURL = getPoster(cellData["poster_path"] as? String)
        // Download an NSData representation of the image at the URL
        let imgData: NSData = NSData(contentsOfURL: imgURL)!
        cell.imageView!.image = UIImage(data: imgData)

        // Get the release date string for display in the subtitle
        let releaseDate: String = cellData["release_date"]as! String
        
        cell.detailTextLabel!.text = releaseDate
        
        return cell
    }
    
    func getPoster(posterPath: String?) ->NSURL
    {
        guard let posterPath = posterPath,
            let baseUrl: String = "http://image.tmdb.org/t/p/w300",
            let urlString: String = "\(baseUrl)" + "\(posterPath)",
            let imgURL: NSURL = NSURL(string: urlString)
        else {
            let defaultImageUrl: NSURL = NSURL(string: "https://assets.tmdb.org/images/logos/var_8_0_tmdb-logo-2_Bree.png")!
            return defaultImageUrl
        }
        return imgURL
    }
    
    // MARK: APIControllerDelegate
    
    //Make the API call
    func getUpcomingMovies()
    {
        //Construct the API URL that you want to call
        let APIkey: String = "" //Replace with your Api Key"
        let APIBaseUrl: String = "https://api.themoviedb.org/3/movie/upcoming?api_key="
        let urlString:String = "\(APIBaseUrl)" + "\(APIkey)"
        
        //Call the API by using the delegate and passing the API url
        self.api.delegate = self
        api.getAPIResults(urlString)
    }
    
    //Handle the Error
    func apiFailedWithError(error: String) {
        let alertController = UIAlertController(title: "Error", message:
            error, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    //Handle the returned data
    func apiSucceededWithResults(results: NSArray) {
        self.searchResultsData = results
        self.appTableView.reloadData()
    }

}

