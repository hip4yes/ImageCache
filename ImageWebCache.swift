//
//  ImageWebCache.swift
//  MGRStore
//
//  Created by Nikita Arkhipov on 04.03.15.
//  Copyright (c) 2015 Jufy. All rights reserved.
//

import UIKit

typealias ImageCompletion = (UIImage?) -> ()

class ImageWebCache: NSObject {
   class var sharedInstance : ImageWebCache {
      struct Static {
         static let instance : ImageWebCache = ImageWebCache()
      }
      return Static.instance
   }
   
   private let imageLoader = ImageLoader.sharedInstance
   private let imageCache = ImageCache.sharedCache
   private var imageViewsDictionary: [NSURL: UIImageView] = [:]

   func storeImage(image: UIImage, forKey key: Key){
      imageCache.storeImage(image, forKey: key)
   }

   func storeImage(image: UIImage, forURL url: NSURL){
      imageCache.storeImage(image, forKey: keyForURL(url))
   }
   
   func imageForURL(url: NSURL, completion: ImageCompletion){
      imageForURL(url, progressBlock: nil, completion: completion)
   }
   
   func imageForURL(url: NSURL, progressBlock: ImageProgressBlock?, completion: ImageCompletion){
      let key = keyForURL(url)
      imageCache.imageForKey(key) { image in
         if let image = image {
            completion(image)
         }else{
            let shouldListen = !self.imageLoader.isLoadingImageForURL(url)
            self.imageLoader.loadImageWithURL(url, progress: progressBlock, completion: self.wrap(completion))
            if shouldListen {
               self.imageLoader.loadImageWithURL(url) { image, _ in
                  if let image = image { self.imageCache.storeImage(image, forKey: key) }
               }
            }
         }
      }
   }
   
   func imageForURL(url: NSURL) -> UIImage? {
      return imageCache.imageForKey(keyForURL(url))
   }
   
   func imageForKey(key: Key, completion: ImageCompletion) {
      imageCache.imageForKey(key, completion: completion)
   }
   
   func imageExistsForKey(key: Key) -> Bool{
      return imageCache.imageExistsForKey(key)
   }
   
   func imageExistsForURL(url: NSURL) -> Bool{
      return imageCache.imageExistsForKey(keyForURL(url))
   }
}

//MARK: - Private
extension ImageWebCache{
   private func keyForURL(url: NSURL) -> Key{
      return url.absoluteString!
   }
   
   private func wrap(block: ImageCompletion) -> ImageLoaderCompletion{
      return { image, _ in block(image) }
   }
}

//MARK: - UIImageView Categories
extension ImageWebCache{
   func loadImageWithURL(url: NSURL, inImageView imageView: UIImageView){
      loadImageWithURL(url, inImageView: imageView, defaultImage: nil)
   }
   
   func loadImageWithURL(url: NSURL, inImageView imageView: UIImageView, defaultImage: UIImage?){
      imageView.image = defaultImage
      imageViewsDictionary[url] = imageView
      imageForURL(url) { image in
         if let imgView = self.imageViewsDictionary[url]{
            GCD_Main {
               imgView.image = image
               self.imageViewsDictionary[url] = nil
            }
         }
      }
   }
}