//
//  Movie.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/3/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import Firebase

class MovieRealm : Object {
    var id: String = ""
}

struct Movie {
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.imageUrl = json["poster_path"].stringValue
        self.voteAverage = json["vote_average"].doubleValue
        self.overview = json["overview"].stringValue
        self.releaseDate = json["release_date"].stringValue
    }
    
    let realm = try! Realm()
    
    var id: String = ""
    
    var title: String = ""
    
    var imageUrl: String = ""
    
    var releaseDate: String = ""
    
    var overview: String = ""
    
    var duration: String = ""
    
    var voteAverage: Double = 0
    
    var myRootRef = Firebase(url: Constants.FIREBASE_URL)
    
    func isFavoriteFireBase(onComplete: (list: [String], value: Bool) -> Void) {
        let deviceRef = myRootRef.childByAppendingPath(UIDevice.currentDevice().identifierForVendor!.UUIDString)
        
        let favoritesRef = deviceRef.childByAppendingPath("favorites")
        
        favoritesRef.observeEventType(.Value, withBlock: { snapshot in
            if let favorites = snapshot.value as? [String] {
                onComplete(list: favorites, value: favorites.indexOf(self.id) >= 0)
                return
            }
            onComplete(list: [], value: false)
        })
    }
    
    func setFavoriteFireBase(onComplete: () -> Void) {
        isFavoriteFireBase { (list, value) in
            guard !value else {
                return
            }
            var newList = list
            newList.append(self.id)
            let deviceRef = self.myRootRef.childByAppendingPath(UIDevice.currentDevice().identifierForVendor!.UUIDString)
            
            let favoritesRef = deviceRef.childByAppendingPath("favorites")
            
            favoritesRef.setValue(newList) { (error, firebase) in
                onComplete()
            }
        }
    }
    
    var isFavorite: Bool {
        get {
            let movieRealms = realm.objects(MovieRealm).filter("id CONTAINS '\(self.id)'")
            return movieRealms.count == 1
        }
        set {
            try! realm.write {
                guard !isFavorite else {
                    return
                }
                let movieRealm = MovieRealm()
                movieRealm.id = self.id
                realm.add(movieRealm)
            }
        }
    }
    
    
    var lowResImageUrl: String {
        return Constants.LOW_RES_IMAGE_ENDPOINT + self.imageUrl
    }
    
    var mediumResImageUrl: String {
        return Constants.MEDIUM_RES_IMAGE_ENDPOINT + self.imageUrl
    }
    
    var highResImageUrl: String {
        return Constants.HIGH_RES_IMAGE_ENDPOINT + self.imageUrl
    }
    
}
