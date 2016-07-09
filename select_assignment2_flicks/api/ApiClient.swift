//
//  ApiClient.swift
//  select_assignment2_flicks
//
//  Created by Hoa Tran on 7/9/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import SwiftyJSON
import Alamofire

class ApiClient {
    
    var currentPage = 1
    
    var currentURL = Constants.NOW_PLAYING_URL
    
    var currentQuery:String? = nil
    
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
    
    func fetchData(before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(currentURL, page: currentPage, query: currentQuery, before: before, completion: completion)
    }
    
    func toArrayOfMovies(jsonArray: [JSON]) -> [Movie] {
        var movies: [Movie] = []
        for element in jsonArray {
            movies.append(Movie(json: element))
        }
        return movies
    }
    
    func fetchData(url:String, page: Int, query: String?, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        before()
        var movies: [Movie] = []
        Alamofire.request(.GET, url, parameters: buildParams(page, query: query)).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                movies = self.toArrayOfMovies(json["results"].arrayValue)
            }
            self.currentPage = page
            self.currentURL = url
            self.currentQuery = query
            completion(movies: movies)
        }
    }
    
    func resetCurrentPage() {
        currentPage = 1
    }
    
    func fetchDataTopRated(page: Int, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.TOP_RATED_URL, page: page, query: nil, before: before, completion: completion)
    }
    
    func fetchDataNowPlaying(page: Int, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.NOW_PLAYING_URL, page: page, query: nil, before: before, completion: completion)
    }
    
    func searchData(page: Int, query: String, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.SEARCH_URL, page: page, query: query, before: before, completion: completion)
    }


}
