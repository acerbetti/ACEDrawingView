//
//  ACEDrawingView+Archieve.h
//  ACEDrawingViewDemo
//
//  Created by Prashant Rane on 11/18/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEDrawingView.h"

@interface ACEDrawingView (Archieve)

- (void)saveDrawingAtPath:(NSString*)path;
- (void)loadDrawingFromPath:(NSString*)path;

@end
