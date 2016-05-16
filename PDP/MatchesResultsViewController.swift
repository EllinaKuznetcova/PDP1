//
//  MatchesResultsViewController.swift
//  PDP
//
//  Created by Ellina Kuznetcova on 16.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class MatchesResultsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var matches: [Match] {
        return Match.MR_findAll() as! [Match]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension MatchesResultsViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.matches.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! MatchCollectionViewCell
        if let matchData = self.matches[indexPath.row].matchesImage {
            cell.imageView.image = UIImage(data: matchData)
        }
        return cell
    }
}
