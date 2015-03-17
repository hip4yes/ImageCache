//
//  ObjHelper.m
//  MerryVideoEditor
//
//  Created by Nikita Arkhipov on 24.02.15.
//  Copyright (c) 2015 Jufy. All rights reserved.
//

#import "ObjHelper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ObjHelper

+(UIImage *)scaleImage:(CGImageRef)image toWidth:(CGFloat)width height:(CGFloat)height{
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGContextRef bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
   CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), image);
   CGImageRef ref = CGBitmapContextCreateImage(bitmap);
   UIImage *result = [UIImage imageWithCGImage:ref];
   
   CGContextRelease(bitmap);
   CGImageRelease(ref);
   CGColorSpaceRelease(colorSpace);
   
   return result;
}

+ (NSString *)cachedFileNameForKey:(NSString *)key {
   const char *str = [key UTF8String];
   if (str == NULL) {
      str = "";
   }
   unsigned char r[CC_MD5_DIGEST_LENGTH];
   CC_MD5(str, (CC_LONG)strlen(str), r);
   NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x.png",
                         r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
   
   return filename;
}


@end


/*
 -(void)insertVideoAsset:(VideoAsset *)asset atTime:(CMTime)time{
 //если ассетов нет, просто добавляем его в массив
 if (_videoAssets.count == 0) {
 [_videoAssets addObject:asset];
 //        [self updateCompostion];
 return;
 }
 
 //ищем индекс нужного ассета и время в нем
 int i = 0;
 VideoAsset *assik = _videoAssets.firstObject;
 CMTime timeLeft = time;
 while (CMTimeGetSeconds(assik.timeRange.duration) < CMTimeGetSeconds(timeLeft)) {
 assik = _videoAssets[++i];
 timeLeft = CMTimeSubtract(timeLeft, asset.timeRange.duration);
 }
 
 NSMutableArray *newArray = [NSMutableArray new];
 NSMutableArray *nextAssets = [NSMutableArray new];
 
 //Если вставка проходит на самой границе одного из видео, то мы его не обрезаем, а просто вставляем после него
 if (CMTimeGetSeconds(timeLeft) < kMinAllowableTimeInterval) {
 [newArray addObjectsFromArray:[_videoAssets subarrayWithRange:NSMakeRange(0, i + 1)]];
 [newArray addObject:asset];
 }else{//если посередине другого видео – то разделяем его на две части и вставляем видео между ними
 NSArray *assets = [assik divideIntoTwoAssetsByTime:timeLeft];
 [newArray addObjectsFromArray:[_videoAssets subarrayWithRange:NSMakeRange(0, i)]];
 [newArray addObject:assets.firstObject];
 [nextAssets addObject:assets.lastObject];
 }
 
 [nextAssets addObjectsFromArray:[_videoAssets subarrayWithRange:NSMakeRange(i + 1, _videoAssets.count - i - 1)]];
 //    //обновляем тайминг следующих видео
 //    for (VideoAsset *vasset in nextAssets) {
 //        vasset.startTime = CMTimeAdd(vasset.startTime, asset.timeRange.duration);
 //    }
 
 [newArray addObjectsFromArray:nextAssets];
 self.videoAssets = newArray;
 //    [self updateCompostion];
 
 }

 */
