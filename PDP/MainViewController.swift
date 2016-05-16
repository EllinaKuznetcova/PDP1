//
//  ViewController.swift
//  PDP
//
//  Created by Ellina Kuznetcova on 11.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    private(set) lazy var operationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "com.flatstack.findMatchesQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .Utility
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addImagesToCompare(sender: AnyObject) {
        let operation = NSBlockOperation(block: {
            let matchesImage = OpenCVWrapper.getMatchesImage(nil, sourceImage2: nil)
            MagicalRecord.saveWithBlock({ (context) in
                let match = Match.MR_createEntityInContext(context)
                match.matchesImage = UIImageJPEGRepresentation(matchesImage, 0.5)
            })
            return
        })
        
        operation.queuePriority = .Low
        self.operationQueue.addOperation(operation)
    }
    
    //MARK: - image picker
    func presentChoosingPhotoSourceController() {
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .ActionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancel)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) {[weak self](alert: UIAlertAction!) -> Void in
            guard let sself = self else {return}
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = sself
            imagePicker.sourceType = .Camera
            sself.presentViewController(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(takePhoto)
        let library = UIAlertAction(title: "Choose from Library", style: .Default) {[weak self](alert: UIAlertAction!) -> Void in
            guard let sself = self else {return}
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = sself
            imagePicker.sourceType = .PhotoLibrary
            sself.presentViewController(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(library)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let matchedImage = OpenCVWrapper.getMatchesImage(pickedImage, sourceImage2: nil)
                self?.imageView.image = matchedImage
            }
            })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

