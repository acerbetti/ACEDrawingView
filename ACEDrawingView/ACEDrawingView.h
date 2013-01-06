//
//  ACEDrawingView.h
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACEDrawingView : UIView

// public properties
@property (nonatomic, assign) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, readonly) NSUInteger undoSteps;

// get the current drawing
@property (nonatomic, readonly) UIImage *image;

// erase all
- (void)clear;

// undo / redo
- (BOOL)canUndo;
- (void)undoLatestStep;

- (BOOL)canRedo;
- (void)redoLatestStep;

@end
