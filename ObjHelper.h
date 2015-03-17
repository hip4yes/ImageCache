//
//  ObjHelper.h
//  MerryVideoEditor
//
//  Created by Nikita Arkhipov on 24.02.15.
//  Copyright (c) 2015 Jufy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ObjHelper : NSObject

+(UIImage *)scaleImage:(CGImageRef)image toWidth:(CGFloat)width height:(CGFloat)height;

+(NSString *)cachedFileNameForKey:(NSString *)key;

@end
