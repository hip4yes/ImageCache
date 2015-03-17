//
//  ImageLoader.swift
//  MGRStore
//
//  Created by Nikita Arkhipov on 04.03.15.
//  Copyright (c) 2015 Jufy. All rights reserved.
//

import UIKit

typealias ImageLoaderCompletion = (UIImage?, NSError?) -> ()
typealias ImageProgressBlock = (Float) -> ()

class ImageLoader: NSObject {
   class var sharedInstance : ImageLoader {
      struct Static {
         static let instance : ImageLoader = ImageLoader()
      }
      return Static.instance
   }
   
   private var loadingDataArray: [LoadingData] = []
   private let accessQueue = dispatch_queue_create("com.Anvix.ImageLoaderQueue", nil)
      
   func loadImageWithURL(url: NSURL, completion: ImageLoaderCompletion){
      loadImageWithURL(url, progress: nil, completion: completion)
   }
   
   func loadImageWithURL(url: NSURL, progress: ImageProgressBlock?, completion: ImageLoaderCompletion){
      mainPrintln("ImageLoader loadImageWithURL \(url.absoluteString!)")
      if let data = dataForURL(url){
         mainPrintln("already has request for that url, adding observer")
         if let progress = progress{
            data.progressBlocks.append(progress)
         }
         data.completions.append(completion)
      }else{
         mainPrintln("new request")
         dispatch_sync(accessQueue) {
            let data = LoadingData(url: url, completion: completion, progressBlock: progress)
            self.loadingDataArray.append(data)
            self.sendRequestForURL(url)
         }
      }
   }
   
   func isLoadingImageForURL(url: NSURL) -> Bool {
      mainPrintln("isLoadingImageForURL \(url.absoluteString!): \(dataForURL(url) != nil)")
      return dataForURL(url) != nil
   }
   
   private func dataForURL(url: NSURL) -> LoadingData!{
      return loadingDataArray.find { $0.url.absoluteString! == url.absoluteString! }
   }
   
   private func sendRequestForURL(url: NSURL){
      var request = NSURLRequest(URL: url)
      var conn = NSURLConnection(request: request, delegate: self, startImmediately: false)!
      conn.start()
   }
   
   private func finishLoadingData(data: LoadingData!, image: UIImage?, error: NSError?){
      mainPrintln("finish loading request for url \(data.url.absoluteString!), image = \(image), error = \(error)")
      if data == nil { return }
      dispatch_sync(accessQueue) {
         data.completion(image, error: error)
         if let index = find(self.loadingDataArray, data){
            self.loadingDataArray.removeAtIndex(index)
         }
      }
   }
}

//MARK: - NSURLConnectionDelegate
extension ImageLoader: NSURLConnectionDelegate{
   func connection(connection: NSURLConnection, didFailWithError error: NSError){
      finishLoadingData(dataForURL(connection.currentRequest.URL), image: nil, error: error)
   }
}

//MARK: - NSURLConnectionDataDelegate
extension ImageLoader: NSURLConnectionDataDelegate{
   func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
      let loadingData = dataForURL(connection.currentRequest.URL)
      loadingData.contentLength = response.expectedContentLength
   }
   
   func connection(connection: NSURLConnection, didReceiveData data: NSData) {
      let loadingData = dataForURL(connection.currentRequest.URL)
      loadingData.data.appendData(data)
      let progress = Float(loadingData.data.length) / Float(loadingData.contentLength!)
      loadingData.progressBlock(progress)
   }
   
   func connectionDidFinishLoading(connection: NSURLConnection!) {
      if let loadingData = dataForURL(connection.currentRequest.URL) {
         GCD_Background {
            let image = UIImage(data: loadingData.data)
            self.finishLoadingData(self.dataForURL(connection.currentRequest.URL), image: image, error: nil)
         }
      }
   }
}

//MARK: - Inner classes
extension ImageLoader{
   class LoadingData: NSObject{
      var contentLength: Int64?
      var data = NSMutableData()
      let url: NSURL
      var completions: [ImageLoaderCompletion]
      var progressBlocks: [ImageProgressBlock] = []
      
      init(url: NSURL, completion: ImageLoaderCompletion){
         self.url = url
         self.completions = [completion]
      }
      
      init(url: NSURL, completion: ImageLoaderCompletion, progressBlock: ImageProgressBlock?){
         self.url = url
         self.completions = [completion]
         if let progressBlock = progressBlock{
            self.progressBlocks = [progressBlock]
         }
      }
      
      func completion(image: UIImage?, error: NSError?){
         GCD_Main {
            self.completions.enumerateAll { $0(image, error) }
         }
      }
      
      func progressBlock(progress: Float){
//         println("progressed \(progress) url \(loadingData.url.absoluteString!)")
         GCD_Main {
            self.progressBlocks.enumerateAll { $0(progress) }
         }
      }
   }
}

//func ==(lhs: ImageLoader.LoadingData, rhs: ImageLoader.LoadingData) -> Bool{
//   return lhs.url.absoluteString == rhs.url.absoluteString
//}
