//
//  MovieList.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/3/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import JTProgressHUD

class MovieList: NSObject {
    
    var movies: [Movie] = []
    
    var tableView: UITableView?
    
    var collectionView: UICollectionView?
    
    var currentPage = Constants.INITIAL_PAGE_NUMBER
    
    var currentURL = Constants.NOW_PLAYING_URL
    
    var currentQuery:String? = nil
    
    var count: Int {
        get {
            return movies.count
        }
    }
    
    func reloadData(jsonArray: [JSON]) {
        movies = []
        for element in jsonArray {
            movies.append(Movie(json: element))
        }
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    func buildParams(page: Int, query: String?) -> [String: AnyObject] {
        let params: NSMutableDictionary = [:]
        params.setValue(Constants.API_KEY, forKey: "api_key")
        params.setValue(page, forKey: "page")
        guard query != nil && !query!.isEmpty else {
            return params as! [String : AnyObject]
        }
        params.setValue(query, forKey: "query")
        return params as! [String : AnyObject]
    }
    
    func resetCurrentPage() {
        currentPage = Constants.INITIAL_PAGE_NUMBER
    }
    
    func fetchDataNext() {
        fetchData(currentURL, page: currentPage + 1, query: currentQuery)
        currentPage = currentPage + 1
    }
    
    func fetchDataPrevious() {
        guard currentPage > Constants.INITIAL_PAGE_NUMBER else {
            fetchData(currentURL, page: currentPage, query: currentQuery)
            return
        }
        fetchData(currentURL, page: currentPage - 1, query: currentQuery)
        currentPage = currentPage - 1
    }
    
    func fetchData(url:String, page: Int, query: String?)  {
        JTProgressHUD.show()
        Alamofire.request(.GET, url, parameters: buildParams(page, query: query)).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                self.reloadData(json["results"].arrayValue)
            }
            JTProgressHUD.hide()
            self.currentPage = page
            self.currentURL = url
            self.currentQuery = query
        }
    }
    
    func fetchDataTopRated(page: Int) {
        fetchData(Constants.TOP_RATED_URL, page: page, query: nil)
    }
    
    func fetchDataNowPlaying(page: Int) {
        fetchData(Constants.NOW_PLAYING_URL, page: page, query: nil)
    }
    
    func searchData(page: Int, query: String) {
        fetchData(Constants.SEARCH_URL, page: page, query: query)
    }
    
    func getElement(index: Int) -> Movie {
        return movies[index]
    }
}
