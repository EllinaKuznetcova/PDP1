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
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    private(set) lazy var operationQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "com.flatstack.findMatchesQueue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .Utility
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SDWebImageManager.sharedManager().delegate = self
        self.loadImageAndProcess()
    }
    
    func loadImageAndProcess() {
        self.imageView.sd_setImageWithURL(NSURL(string: "http://www.gen-x.ru/images/zags.jpg"), placeholderImage: UIImage(named: "info.png"), options: [SDWebImageOptions.TransformAnimatedImage])
    }

    @IBAction func removeImage(sender: AnyObject) {
        self.imageView.image = nil
        self.addImageButton.setTitle("Add image to compare", forState: .Normal)
    }

    @IBAction func addImagesToCompare(sender: AnyObject) {
        self.presentChoosingPhotoSourceController()
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
    
    func imageProcessing(pickedImage : UIImage, completionBlock: (UIImage) -> ()){
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            let width: CGFloat = 200
            let height = pickedImage.size.height * width / pickedImage.size.width
            let size = CGSizeMake(width, height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            pickedImage.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            dispatch_async(dispatch_get_main_queue(), {
                completionBlock(scaledImage)
            })
        })
    }

}

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageProcessing(pickedImage, completionBlock: { [weak self] (pickedImage) in
                let operation = NSBlockOperation(block: {
                    let matchesImage = OpenCVWrapper.getMatchesImage(pickedImage, sourceImage2: self?.imageView.image)
                    MagicalRecord.saveWithBlock({ (context) in
                        let match = Match.MR_createEntityInContext(context)
                        match.matchesImage = UIImageJPEGRepresentation(matchesImage, 0.5)
                    })
                })
                
                operation.queuePriority = .Low
                self?.operationQueue.addOperation(operation)
                })
            
            self.infoButton.hidden = false
            
            let delayInSeconds : UInt64 = 1;
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * NSEC_PER_SEC))
            dispatch_after(popTime, dispatch_get_main_queue(), {[weak self] in
                self?.infoButton.hidden = true
                })

        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MainViewController : SDWebImageManagerDelegate {
    func imageManager(imageManager: SDWebImageManager!, transformDownloadedImage image: UIImage!, withURL imageURL: NSURL!) -> UIImage! {
        let width: CGFloat = 200
        let height = image.size.height * width / image.size.width
        let size = CGSizeMake(width, height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

