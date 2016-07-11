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
    
    
    func setData(movie: Movie) {
        overview.text = movie.overview
        title.text = movie.title
        
        let imageURL = NSURLRequest(URL: NSURL(string: movie.lowResImageUrl)!)
        
        thumbnailImage.setImageWithURLRequest(imageURL, placeholderImage: nil, success: { (request, response, image) in
            self.thumbnailImage.setImageWithFadingIn(image)
            }, failure: nil)
    }
}
