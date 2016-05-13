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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = OpenCVWrapper.getMatchesImage(nil, path2: nil)
        self.imageView.image = image
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
            SVProgressHUD.show()
        }
        alertController.addAction(takePhoto)
        let library = UIAlertAction(title: "Choose from Library", style: .Default) {[weak self](alert: UIAlertAction!) -> Void in
            guard let sself = self else {return}
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = sself
            imagePicker.sourceType = .PhotoLibrary
            sself.presentViewController(imagePicker, animated: true, completion: nil)
            SVProgressHUD.show()
        }
        alertController.addAction(library)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            
            if let pickedUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
                let path = pickedUrl.absoluteString
                
            }
            else {
                SVProgressHUD.dismiss()
            }
            })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

