//
//  RealmHelper.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/17/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import RealmSwift

struct RealmHelper {
    
    static let realm = try! Realm()
    
    static func isFavorite(id: String) -> Bool {
        return realm.objects(MovieRealm.self).filter("id ='\(id)'").count == 1
    }
    
    static func getMovieRealm(id: String) -> MovieRealm {
        return realm.objects(MovieRealm.self).filter("id ='\(id)'").first!
    }
    
    static func setFavorited(id: String) {
        try! realm.write({
            let movieRealm = MovieRealm()
            movieRealm.id = id
            realm.add(movieRealm)
        })
    }
    
    static func setUnfavorited(id: String) {
        try! realm.write({
            realm.delete(getMovieRealm(id))
        })
    }

}
