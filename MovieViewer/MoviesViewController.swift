//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by MacbookPro on 1/7/16.
//  Copyright © 2016 MacbookPro. All rights reserved.
//

import UIKit
import AFNetworking
import Foundation
import SystemConfiguration


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var networkError: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var netInfo : NSString = ""
 
 
  
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
 
        networkError.hidden = true
        
          NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        
        
         
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
     
        
        
        // Do any additional setup after loading the view.
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    

    func onRefresh() {
        
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        Reach().monitorReachabilityChanges()
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        if let movies = movies {
            return movies.count
        } else {
           
            return 0
 
        }
        

    }
    
    
 
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overView = movie["overview"] as! String
      
        let posterPath = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overViewLabel.text = overView
        cell.posterView.setImageWithURL(imageUrl!)
        
        
        
        
        
        return cell
    }
   
    
    func loadData() {
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            
                            self.movies = responseDictionary ["results"] as! [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
        

    
    }
    


    func networkStatusChanged(notification: NSNotification) {
        let userInfo = notification.userInfo
       
        netInfo = userInfo! ["Status"] as! NSString
        if netInfo == "Online (WiFi)" {
           networkError.hidden = true
        } else {
            networkError.hidden = false
 
            
        }
        
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



 