//
//  MovieCollectionViewCell.swift
//  select_assignment2_flicks
//
//  Created by Hoa Tran on 7/9/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var thumbnailImage: UIImageView!
    
    override func awakeFromNib() {
        thumbnailImage.layer.cornerRadius = Constants.IMAGE_RADIUS_CORNER
        thumbnailImage.clipsToBounds = true
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 2
    }
    
    func setData(movie: Movie) {
        title.text = movie.title
        
        let imageURL = NSURLRequest(URL: NSURL(string: movie.lowResImageUrl)!)
        
        thumbnailImage.setImageWithURLRequest(imageURL, placeholderImage: nil, success: { (request, response, image) in
            self.thumbnailImage.setWithImageWithVerticalFlipping(image)
            }, failure: nil)
    }
}
