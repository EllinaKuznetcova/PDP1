//
//  AppDelegate.swift
//  PDP
//
//  Created by Ellina Kuznetcova on 11.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //setup libraries
        self.setupLibraries()
        
        return true
    }
}

//MARK: - Setup Services and Libraries
private extension AppDelegate {
    
    func setupLibraries () {
        
        //Setting MagicalRecord
        self.setupMagicalRecords()
        
        
        //Setting SDWebImage's cache
        self.setupSDWebImage()
    }
    func setupMagicalRecords () {
        MagicalRecord.setupAutoMigratingCoreDataStack()
        MagicalRecord.setShouldDeleteStoreOnModelMismatch(true)
        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.Off)
    }
    
    func setupSDWebImage() {
        
        let imageDownloader: SDWebImageDownloader = SDWebImageDownloader.sharedDownloader()
        imageDownloader.downloadTimeout           = 60.0
        
        let imageCache: SDImageCache = SDImageCache.sharedImageCache()
        imageCache.maxCacheSize     = 1024*1024*20  // 20 mb on disk
        imageCache.maxMemoryCost    = 1024*1024*10  // 10 mb in memory
        imageCache.maxCacheAge      = 60*60*24*30   // 1 month
        imageCache.maxMemoryCountLimit = 10         // 10 objects in memory
        imageCache.shouldDecompressImages = true
    }

}

