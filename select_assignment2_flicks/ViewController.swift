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
import JTProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func onChangeDisplayView(sender: AnyObject) {
        switch (sender.selectedSegmentIndex) {
        case 0:
            setDisplayMode(.List)
        case 1:
            setDisplayMode(.Grid)
        default:
            setDisplayMode(.List)
        }
    }
    
    var viewMode: ViewMode = .NowPlaying
        
    enum ViewMode {
        case NowPlaying, TopRated
    }
    
    enum DisplayMode {
        case Grid, List
    }
    
    func setDisplayMode(displayMode: DisplayMode) {
        switch displayMode {
        case .Grid:
            tableView.hidden = true
            collectionView.hidden = false
            break
        case .List:
            tableView.hidden = false
            collectionView.hidden = true
        }
    }
    
    let apiClient = ApiClient()
    
    var movies: [Movie] = []
        
    func willFetchingData() {
        JTProgressHUD.show()
    }
    
    func onFetchingDataComplete(movies: [Movie]) {
        self.movies.appendContentsOf(movies)
        JTProgressHUD.hide()
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDisplayMode(.List)
        switch (viewMode) {
        case .NowPlaying:
            apiClient.fetchDataNowPlaying(1, before: {
                self.willFetchingData()
            }) { (movies) in
                self.onFetchingDataComplete(movies)
            }
        case .TopRated:
            apiClient.fetchDataTopRated(1, before: {
                self.willFetchingData()
            }) { (movies) in
                self.onFetchingDataComplete(movies)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.errorView.hidden = getConnectionStatus()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: -reload data methods
extension ViewController {
    func reloadViewData() {
        tableView.reloadData()
        collectionView.reloadData()
    }
}

// MARK: -TableView methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        cell.setData(movie)
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
        
        self.errorView.hidden = getConnectionStatus()

        let currentOffset = scrollView.contentOffset.y
        
        if currentOffset < 0 {
            apiClient.resetCurrentPage()
            apiClient.fetchData({
                self.movies = []
                self.willFetchingData()
                }, completion: { (movies) in
                    self.onFetchingDataComplete(movies)
            })

            return
        }
        if currentOffset > scrollView.contentSize.height - scrollView.frame.height {
            apiClient.currentPage = apiClient.currentPage + 1
            apiClient.fetchData({
                self.willFetchingData()
                }, completion: { (movies) in
                    self.onFetchingDataComplete(movies)
            })
            return
        }
    }
}

// MARK: -CollectionView methods

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MovieCollectionViewCell
        let movie = movies[indexPath.row]
        cell.setData(movie)
        return cell
    }
    
}

// MARK: -segue to details view
extension ViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var indexPath:NSIndexPath?
        switch sender {
            case is UITableViewCell:
                indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            case is UICollectionViewCell:
                indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)!
            default: break
        }
        
        let movie = movies[indexPath!.row]
        let viewDetails = segue.destinationViewController as! ViewDetailsController
        viewDetails.movie = movie
    }
}

