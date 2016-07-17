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
import MGSwipeTableCell
import Social
import Firebase

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
    
    @IBAction func onFiltersTap(sender: AnyObject) {
        self.performSegueWithIdentifier("filters", sender: self)
    }
    
    var fireBaseRef = Firebase(url: Constants.FIREBASE_URL)

    
    var viewMode: ViewMode = .NowPlaying
    
    let searchBar = UISearchBar()
    
    var filterButton = UIBarButtonItem()
    
    var fireBaseFavoriteIds: [String] = []
    
    enum ViewMode {
        case NowPlaying, TopRated, Search
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
        
    func willFetchData() {
        JTProgressHUD.show()
    }
    
    func onFetchingDataComplete(movies: [Movie]) {
        let firstIndex = self.movies.count
        let lastIndex = firstIndex + movies.count
        self.movies.appendContentsOf(movies)
        // here, we can update the favorited status. 
        for index in firstIndex..<lastIndex {
            self.movies[index].favorited = RealmHelper.isFavorite(self.movies[index].id)
        }
        
        /*
 
         firebaseRef.observeSingleEventOfType
        */
        JTProgressHUD.hide()
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        
        filterButton = UIBarButtonItem(title: "Filters", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(onFiltersTap))
        
        super.viewDidLoad()
        
        setDisplayMode(.List)
        switch (viewMode) {
        case .NowPlaying:
            apiClient.fetchDataNowPlaying(1, before: {
                self.willFetchData()
            }) { (movies) in
                self.onFetchingDataComplete(movies)
            }
        case .TopRated:
            apiClient.fetchDataTopRated(1, before: {
                self.willFetchData()
            }) { (movies) in
                self.onFetchingDataComplete(movies)
            }
        case .Search:
            navigationItem.titleView = searchBar
            navigationItem.rightBarButtonItem = filterButton
            navigationItem.leftBarButtonItem = nil
            apiClient.searchData(1, query: "", before: {
                self.willFetchData()
                }, completion: { (movies) in
                    self.onFetchingDataComplete(movies)
            })
            searchBar.delegate = self
            searchBar.becomeFirstResponder()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.errorView.hidden = getConnectionStatus()
        
        let deviceRef = fireBaseRef.childByAppendingPath(UIDevice.currentDevice().identifierForVendor!.UUIDString)
        let favoritesRef = deviceRef.childByAppendingPath("favorites")
        
        favoritesRef.observeSingleEventOfType(.ChildAdded, withBlock:  { (snapshot) in
            if let favoriteIds = snapshot.value as? [String] {
                self.fireBaseFavoriteIds = favoriteIds
                for favoriteId in favoriteIds {
                    RealmHelper.setFavorited(favoriteId)
                }
            }
        })
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//MARK: -Searchbar
extension ViewController: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        movies = []
        apiClient.searchData(1, query: searchText, before: {
            self.willFetchData()
            }, completion: { (movies) in
                self.onFetchingDataComplete(movies)
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        apiClient.fetchDataNowPlaying(1, before: { 
            self.movies = []
            self.willFetchData()
            }) { (movies) in
                self.onFetchingDataComplete(movies)
        }
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
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
        guard movies.count > 0 else {
            let errorLabel = errorView.subviews[0] as! UILabel
            errorLabel.text = "No movies found"
            errorView.hidden = false
            return 0
        }
        errorView.hidden = true
        return movies.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MovieCell
        guard indexPath.row < movies.count else {
            return cell
        }
        let movie = movies[indexPath.row]
        cell.setData(movie, buttonShare: getButtonShare(movie.title), buttonFavorite: getButtonFavorite(movie.favorited, indexPath: indexPath))
        
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
                self.willFetchData()
                }, completion: self.onFetchingDataComplete)

            return
        }
        if currentOffset > scrollView.contentSize.height - scrollView.frame.height {
            apiClient.currentPage = apiClient.currentPage + 1
            apiClient.fetchData(self.willFetchData, completion: self.onFetchingDataComplete)
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
        switch segue.identifier! {
        case "viewDetails":
                let movie = movies[indexPath!.row]
                let viewDetails = segue.destinationViewController as! ViewDetailsController
                viewDetails.movie = movie
        case "filters":
                let filters = segue.destinationViewController as! FilterViewController
                filters.delegate = self
                filters.datasource = self
        default:
            break
        }
    }
}

//MARK: -filter methods
extension ViewController: FilterViewControllerDelegate, FilterViewControllerDataSource {
    func filterViewController(showAdultContent: Bool, releaseYear: Int?, primaryReleaseYear: Int?) {
        apiClient.searchData(1, includeAdult: showAdultContent, releaseYear: releaseYear, primaryReleaseYear: primaryReleaseYear, before: { 
            self.willFetchData()
            }) { (movies) in
                self.movies = []
                self.onFetchingDataComplete(movies)
        }
    }
    
    func showAdultContent() -> Bool {
        return self.apiClient.currentIncludeAdult!
    }
    
    func releaseYear() -> Int? {
        return self.apiClient.currentReleaseYear
    }
    
    func primaryReleaseYear() -> Int? {
        return self.apiClient.currentPrimaryReleaseYear
    }
}

//MARK: -swipe buttons

extension ViewController {
    func getButtonFavorite(favorited: Bool, indexPath: NSIndexPath) -> MGSwipeButton {
        let leftButtonText = favorited ? "Unfavorite" : "Favorite"
        return MGSwipeButton(title: leftButtonText, backgroundColor: UIColor.blackColor()) { (cell) -> Bool in
            self.movies[indexPath.row].favorited =  !favorited
            let movie = self.movies[indexPath.row]
            switch movie.favorited {
            case true:
                RealmHelper.setFavorited(movie.id)
                self.fireBaseFavoriteIds.append(movie.id)
                
            case false:
                if let index = self.fireBaseFavoriteIds.indexOf(movie.id) {
                    self.fireBaseFavoriteIds.removeAtIndex(index)
                } else {
                    self.fireBaseFavoriteIds.append(movie.id)
                }
                RealmHelper.setUnfavorited(movie.id)

            }
            
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            let deviceRef = self.fireBaseRef.childByAppendingPath(UIDevice.currentDevice().identifierForVendor!.UUIDString)
            let favoritesRef = deviceRef.childByAppendingPath("favorites")
            favoritesRef.setValue(self.fireBaseFavoriteIds)
            
            return true
        }
    }
    
    func getButtonShare(sharingText: String) -> MGSwipeButton {
        return MGSwipeButton(title: "Share", backgroundColor: UIColor.blackColor()) { (cell) -> Bool in
            let actionSheet = UIAlertController(title: "", message: "Share", preferredStyle:.ActionSheet)
            
            let tweetAction = UIAlertAction(title: "Share on Twitter", style: .Default, handler: { (action) in
                guard SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) else {
                    let alertViewController = UIAlertController(title: "Error", message: "You are not logged in to Twitter", preferredStyle: .Alert)
                    alertViewController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertViewController, animated: true, completion: nil)
                    return
                }
                let twitterComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                twitterComposeViewController.setInitialText(sharingText)
            })
            
            let facebookAction = UIAlertAction(title: "Share on Facebook", style: .Default, handler: { (action) in
                guard SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) else {
                    let alertViewController = UIAlertController(title: "Error", message: "You are not logged in to Facebook", preferredStyle: .Alert)
                    alertViewController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertViewController, animated: true, completion: nil)
                    return
                }
                let facebookComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                facebookComposeViewController.setInitialText(sharingText)
            })
            
            let moreAction = UIAlertAction(title: "More", style: .Default, handler: { (action) in
                let activityViewController = UIActivityViewController(activityItems: [sharingText], applicationActivities: nil)
                self.presentViewController(activityViewController, animated: true, completion: nil)
            })
            
            let dismissAction = UIAlertAction(title: "Close", style: .Default, handler: { (action) in
            })
            
            actionSheet.addAction(tweetAction)
            actionSheet.addAction(facebookAction)
            actionSheet.addAction(moreAction)
            actionSheet.addAction(dismissAction)
            
            self.presentViewController(actionSheet, animated: true, completion: nil)
            
            return true
        }
    }
}


