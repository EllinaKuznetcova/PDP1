//
//  OpenCVWrapper.h
//  PDP
//
//  Created by Ellina Kuznetcova on 11.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "opencv2/nonfree/features2d.hpp"
#include "opencv2/highgui/highgui.hpp"


@interface OpenCVWrapper : NSObject

+ (UIImage *)getMatchesImage:(NSString*)path1 path2:(NSString*)path2;

@end
