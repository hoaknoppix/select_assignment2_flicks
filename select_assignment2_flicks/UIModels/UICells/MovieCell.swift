//
//  MovieCell.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/3/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MovieCell: MGSwipeTableCell {

    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var overview: UILabel!
    
    
    func setData(movie: Movie, buttonShare: MGSwipeButton, buttonFavorite: MGSwipeButton) {
        overview.text = movie.overview
        title.text = movie.title
        
        let imageURL = NSURLRequest(URL: NSURL(string: movie.lowResImageUrl)!)
        

        
        thumbnailImage.setImageWithURLRequest(imageURL, placeholderImage: nil, success: { (request, response, image) in
            self.thumbnailImage.setImageWithFadingIn(image)
            }, failure: nil)
        
        
        self.leftButtons = [buttonFavorite]
        self.leftExpansion.buttonIndex = 0
        
        self.rightButtons = [buttonShare]
        self.rightExpansion.buttonIndex = 0
        //        movie.isFavoriteFireBase { (list, value) in
        //            cell.backgroundColor = value ? UIColor.yellowColor() : UIColor.whiteColor()
        
        self.backgroundColor = movie.favorited ? UIColor.yellowColor() : UIColor.whiteColor()
        

    }
}
