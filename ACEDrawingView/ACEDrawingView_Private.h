//
//  ACEDrawingView_Private.h
//  ACEDrawingViewDemo
//
//  Created by Prashant Rane on 11/18/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEDrawingView.h"

@interface ACEDrawingView () {
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
}

@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSMutableArray *bufferArray;
@property (nonatomic, strong) id<ACEDrawingTool> currentTool;
@property (nonatomic, strong) UIImage *image;
@end
