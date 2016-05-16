//
//  OpenCVWrapper.m
//  PDP
//
//  Created by Ellina Kuznetcova on 11.05.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "UIImage+OpenCV.h"

using namespace cv;

@implementation OpenCVWrapper

+(UIImage *)getMatchesImage:(UIImage*)sourceImage1 sourceImage2:(UIImage*)sourceImage2 {
    string sPath1 = string([[[NSBundle mainBundle] pathForResource:@"image1" ofType:@"jpg"] UTF8String]);
    string sPath2 = string([[[NSBundle mainBundle] pathForResource:@"image2" ofType:@"jpg"] UTF8String]);
    NSLog(@"Keypoint Detects");
    //-- Step 1: Detect the keypoints using SURF Detector
    
    int minHessian = 400;
    SurfFeatureDetector detector( minHessian );
    std::vector<KeyPoint> keypoints_object, keypoints_scene;
    Mat image1 = imread(sPath1,CV_LOAD_IMAGE_GRAYSCALE);
    Mat image2 = imread(sPath2, CV_LOAD_IMAGE_GRAYSCALE);
    detector.detect( image1, keypoints_object );
    detector.detect( image2, keypoints_scene );
    
    //-- Step 2: Calculate descriptors (feature vectors)
    NSLog(@"Descriptor Detects");
    SurfDescriptorExtractor extractor;
    Mat descriptors_object, descriptors_scene;
    extractor.compute( image1, keypoints_object, descriptors_object );
    extractor.compute( image2, keypoints_scene, descriptors_scene );
    
    //-- Step 3: Matching descriptor vectors using FLANN matcher
    NSLog(@"Matching Detects");
    BFMatcher matcher;
    std::vector< DMatch > matches;
    matcher.match( descriptors_object, descriptors_scene, matches );
    printf("%lu", matches.size());
    
    float distanceSum = 0;
    int distanceCount = 0;
    
    for(std::vector<DMatch>::iterator it = matches.begin(); it != matches.end(); ++it) {
        distanceSum += (*it).distance;
        distanceCount += 1;
    }
    
    float thres = (distanceSum/distanceCount) * 0.5;
    
    std::vector< DMatch > selMatches;
    for(std::vector<DMatch>::iterator it = matches.begin(); it != matches.end(); ++it) {
        if ((*it).distance < thres) {
            selMatches.insert(selMatches.begin(), (*it));
        }
    }
    
    cv::Size s1 = image1.size();
    cv::Size s2 = image2.size();
    int height1 = s1.height;
    int width1 = s1.width;
    int height2 = s2.height;
    int width2 = s2.width;
    
    int maxHeight = height1;
    if (height2 > height1) {
        maxHeight = height2;
    }
    
    Mat mat = Mat(maxHeight, width1 + width2, CV_8UC1, Scalar::all(0));
    
    for(int i = 0; i < height1; i++) {
        for (int j = 0; j < width1; j++) {
            mat.at<uchar>(i,j) = image1.at<uchar>(i,j);
        }
    }
    
    for(int i = 0; i < height2; i++) {
        for (int j = 0; j < width2; j++) {
            mat.at<uchar>(i,width1 + j) = image2.at<uchar>(i,j);
        }
    }
    
    for(std::vector<DMatch>::iterator it = selMatches.begin(); it != selMatches.end(); ++it) {
        int queryIdx = (*it).queryIdx;
        KeyPoint kp1 = keypoints_object[queryIdx];
        cv::Point p1 = cv::Point(kp1.pt.x, kp1.pt.y);
        
        int trainIdx = (*it).trainIdx;
        KeyPoint kp2 = keypoints_object[trainIdx];
        cv::Point p2 = cv::Point(kp2.pt.x + width1, kp2.pt.y);
        
        cv::line(mat, p1, p2, Scalar(1,1,0));
    }
    

    
    NSData *data = [NSData dataWithBytes:mat.data length:mat.elemSize()*mat.total()];
    CGColorSpaceRef colorSpace;
    
    if (mat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(mat.cols,                                 //width
                                        mat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * mat.elemSize(),                       //bits per pixel
                                        mat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
