//
//  ViewController.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/2/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AFNetworking
import ReachabilitySwift

class ViewController: UIViewController {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let movieList = MovieList()
    
    
    let lockQueue = dispatch_queue_create("vn.coderschool.LockQueue", nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBar = self.navigationController!.navigationBar
        navigationBar.barStyle = .Black
        navigationBar.barTintColor = UIColor.redColor()
        navigationBar.tintColor = UIColor.whiteColor()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        movieList.tableView = tableView
        movieList.fetchDataNowPlaying(1)
        tableView.delegate = self
        tableView.dataSource = self
        self.errorView.hidden = getConnectionStatus()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: -reload data methods
extension ViewController {
    func reloadViewData() {
        //switch if the current view is collection or tableView
        tableView.reloadData()
    }
}

// MARK: -TableView methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MovieCell
        let movie = movieList.getElement(indexPath.row)
        cell.overview.text = movie.overview
        cell.title.text = movie.title
        cell.thumbnailImage.setImageWithURL(NSURL(string: movie.lowResImageUrl)!)
        return cell
    }
    
    func getConnectionStatus() -> Bool {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            
        } catch {
            print("Unable to create Reachability")
            return false
        }
        return reachability.isReachable()
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset < 0 {
            self.errorView.hidden = getConnectionStatus()
            self.movieList.fetchDataPrevious()
            return
        }
        if currentOffset > scrollView.contentSize.height - scrollView.frame.height {
            self.errorView.hidden = getConnectionStatus()
            self.movieList.fetchDataNext()
            tableView.setContentOffset(CGPointZero, animated:false)
            return
        }
    }
}
    
// Playing with dispatch one and after that I thought if the code go to the previous method, it's more simple
//    func scrollViewDidScroll(scrollView: UIScrollView) {

//        dispatch_once(&token) { () -> Void in
//            if currentOffset <= 0 {
//                self.movieList.fetchDataPrevious()
//                return
//            }
//            if currentOffset >= scrollView.contentSize.height - scrollView.frame.height {
//                self.movieList.fetchDataNext()
//                return
//            }
//        }

//  }

// MARK: -segue to details view
extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(cell)!
            let movie = movieList.getElement(indexPath.row)
            let viewDetails = segue.destinationViewController as! ViewDetailsController
            viewDetails.movie = movie
            return
        }
        
    }
}

