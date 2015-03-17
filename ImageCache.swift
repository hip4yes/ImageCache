//
//  ImageCache.swift
//  MerryVideoEditor
//
//  Created by Nikita Arkhipov on 02.03.15.
//  Copyright (c) 2015 Jufy. All rights reserved.
//

import UIKit
import Foundation

typealias Key = String

class ImageCache {

   class var sharedCache : ImageCache {
      struct Static {
         static let instance : ImageCache = ImageCache()
      }
      return Static.instance
   }
   
   private var loadedImages: [Key: UIImage] = [:]
   private lazy var diskCachePath = documentsDirectory()
   
   init() {
//      NSNotificationCenter.defaultCenter().addObserver(self, selector: "clearInMemoryCache:", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
   }
   
   deinit{
//      NSNotificationCenter.defaultCenter().removeObserver(self)
   }
   
   func storeImage(image: UIImage, forKey key: Key){
      mainPrintln("ImageCache store image for key \(key)")
      loadedImages[key] = image
      UIImagePNGRepresentation(image).writeToFile(cachePathForKey(key), atomically: true)
   }
   
   func imageForKey(key: Key) -> UIImage? {
      mainPrintln("ImageCache imageForKey \(key): inMemCache \(loadedImages[key] != nil), inCache \(imageExistsForKey(key))")
      if let image = loadedImages[key] { return image }
      if let data = NSData(contentsOfFile: cachePathForKey(key)) {
         let image = UIImage(data: data)
         loadedImages[key] = image
         return image
      }
      return nil
   }
   
   func imageForKey(key: Key, completion: (UIImage?) -> ()) {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
         let image = self.imageForKey(key)
         dispatch_async(dispatch_get_main_queue(), {
            completion(image)
         })
      })
   }
   
   func imageExistsForKey(key: Key) -> Bool{
      if loadedImages[key] != nil { return true }
      return NSFileManager.defaultManager().fileExistsAtPath(cachePathForKey(key))
   }
   
   func clearInMemoryCache(notification: NSNotification?){
      loadedImages = [:]
   }
   
   private func cachePathForKey(key: Key) -> String{
      return diskCachePath.stringByAppendingPathComponent(ObjHelper.cachedFileNameForKey(key))
   }
}

func documentsDirectory() -> String{
   return (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [NSString])[0]
}

