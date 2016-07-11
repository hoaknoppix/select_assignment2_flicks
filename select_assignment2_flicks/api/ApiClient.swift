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
    
    var currentQuery: String? = nil
    
    var currentIncludeAdult: Bool? = true
    var currentReleaseYear: Int? = nil
    var currentPrimaryReleaseYear: Int? = nil
    
    static func getApiYearValue(index: Int) -> Int? {
        return index == 0 ? nil : Constants.YEARS[index - 1]
    }
    
    static func getPickerYearIndex(value: Int?) -> Int {
        return value == nil ? 0 : Constants.YEARS.indexOf(value!)! + 1
    }
    
    func buildParams(page: Int, query: String?, includeAdult: Bool?, releaseYear: Int?, primaryReleaseYear: Int?) -> [String: AnyObject] {
        let params: NSMutableDictionary = [:]
        params.setValue(Constants.API_KEY, forKey: "api_key")
        params.setValue(page, forKey: "page")
        guard query != nil && !query!.isEmpty else {
            return params as! [String : AnyObject]
        }
        params.setValue(query, forKey: "query")
        if includeAdult != nil {
            params.setValue(includeAdult, forKey: "include_adult")
        }
        if releaseYear != nil {
            params.setValue(releaseYear, forKey: "year")
        }
        if primaryReleaseYear != nil {
            params.setValue(primaryReleaseYear, forKey: "primary_release_year")
        }
        return params as! [String : AnyObject]
    }
    
    func fetchData(before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(currentURL, page: currentPage, query: currentQuery, includeAdult: currentIncludeAdult, releaseYear: currentReleaseYear, primaryReleaseYear: currentPrimaryReleaseYear, before: before, completion: completion)
    }
    
    func toArrayOfMovies(jsonArray: [JSON]) -> [Movie] {
        var movies: [Movie] = []
        for element in jsonArray {
            movies.append(Movie(json: element))
        }
        return movies
    }
    
    func fetchData(url:String, page: Int, query: String?, includeAdult: Bool?, releaseYear: Int?, primaryReleaseYear: Int?, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        before()
        var movies: [Movie] = []
        Alamofire.request(.GET, url, parameters: buildParams(page, query: query, includeAdult: includeAdult, releaseYear: releaseYear, primaryReleaseYear: primaryReleaseYear)).responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                movies = self.toArrayOfMovies(json["results"].arrayValue)
            }
            self.currentPage = page
            self.currentURL = url
            self.currentQuery = query
            self.currentIncludeAdult = includeAdult
            self.currentReleaseYear = releaseYear
            self.currentPrimaryReleaseYear = primaryReleaseYear
            completion(movies: movies)
        }
    }
    
    func resetCurrentPage() {
        currentPage = 1
    }
    
    func fetchDataTopRated(page: Int, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.TOP_RATED_URL, page: page, query: nil, includeAdult: nil, releaseYear: nil, primaryReleaseYear: nil, before: before, completion: completion)
    }
    
    func fetchDataNowPlaying(page: Int, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.NOW_PLAYING_URL, page: page, query: nil, includeAdult: nil, releaseYear: nil, primaryReleaseYear: nil, before: before, completion: completion)
    }
    
    func searchData(page: Int, includeAdult: Bool?, releaseYear: Int?, primaryReleaseYear: Int?, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.SEARCH_URL, page: page, query: currentQuery, includeAdult: includeAdult, releaseYear: releaseYear, primaryReleaseYear: primaryReleaseYear, before: before, completion: completion)
    }
    
    func searchData(page: Int, query: String, before: () -> Void, completion: (movies: [Movie]) -> Void) {
        fetchData(Constants.SEARCH_URL, page: page, query: query, includeAdult: currentIncludeAdult, releaseYear: currentReleaseYear, primaryReleaseYear: currentPrimaryReleaseYear, before: before, completion: completion)
    }


}
