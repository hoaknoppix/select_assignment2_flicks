//
//  Constants.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/3/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit

class Constants {
    
    private init() {
        //util class
    }
    
    static var YEARS: [Int] {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        let currentYear =  components.year
        return Array(1899...currentYear).reverse()
    }
    
    static let LOW_RES_IMAGE_ENDPOINT = "https://image.tmdb.org/t/p/w92"
    
    static let MEDIUM_RES_IMAGE_ENDPOINT =
        "https://image.tmdb.org/t/p/w342"
    
    static let HIGH_RES_IMAGE_ENDPOINT = "https://image.tmdb.org/t/p/original"
    
    static let API_KEY = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    static let NOW_PLAYING_URL = "https://api.themoviedb.org/3/movie/now_playing"
    
    static let TOP_RATED_URL = "https://api.themoviedb.org/3/movie/top_rated"
    
    static let SEARCH_URL = "https://api.themoviedb.org/3/search/movie"
    
    static let IMAGE_RADIUS_CORNER:CGFloat = 10
    
}
