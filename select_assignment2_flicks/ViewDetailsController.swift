//
//  ViewDetailsController.swift
//  select_assignment2_flicks
//
//  Created by hoaqt on 7/3/16.
//  Copyright © 2016 com.noron. All rights reserved.
//

import UIKit
import AFNetworking

class ViewDetailsController: UIViewController {
    @IBAction func movieInfoViewSwipeUp(sender: UISwipeGestureRecognizer) {
        
        UIView.animateWithDuration(0.3, animations: {
            self.movieInfoView.frame = CGRectOffset(self.movieInfoView.frame, 0, -100)
            }) { (complete) in
                UIView.animateWithDuration(0.3) {
                    self.movieInfoView.frame = CGRectOffset(self.movieInfoView.frame, 0, 100)
                }
        }
    }
    
    @IBOutlet weak var movieInfoView: UIView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releasedDate: UILabel!
    
    var movie: Movie?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.title = movie?.title
        movieImage.setImageWithURL(NSURL(string: movie!.lowResImageUrl)!)
        movieImage.setImageWithURL(NSURL(string: movie!.highResImageUrl)!)
        movieTitle.text = movie!.title
        overview.text = movie!.overview
        releasedDate.text = movie!.releaseDate
    }
}
