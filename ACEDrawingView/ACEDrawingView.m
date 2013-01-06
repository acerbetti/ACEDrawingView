//
//  ACEDrawingView.m
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEDrawingView.h"
#import <QuartzCore/QuartzCore.h>

@interface UIColoredBezierPath : UIBezierPath
@property (nonatomic, strong) UIColor *lineColor;
@end

#pragma mark -

@implementation UIColoredBezierPath
@end

#pragma mark -

@interface ACEDrawingView ()
@property (nonatomic, strong) NSMutableArray *pathArray;
@property (nonatomic, strong) NSMutableArray *bufferArray;
@property (nonatomic, strong) UIColoredBezierPath *bezierPath;
@end

#pragma mark -

@implementation ACEDrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure
{
    // init the private arrays
    self.pathArray = [NSMutableArray array];
    self.bufferArray = [NSMutableArray array];
    
    // set the default values for the public properties
    self.lineColor = [UIColor blackColor];
    self.lineWidth = 10.0f;
}


#pragma mark - Drawing

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (void)drawRect:(CGRect)rect
{
    for (UIColoredBezierPath *path in self.pathArray)
    {
        [path.lineColor setStroke];
        [path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    }
}


#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // init the bezier path
    self.bezierPath = [UIColoredBezierPath new];
    self.bezierPath.lineColor = self.lineColor;
    self.bezierPath.lineWidth = self.lineWidth;
    self.bezierPath.lineCapStyle = kCGLineCapRound;
    [self.pathArray addObject:self.bezierPath];
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    [self.bezierPath moveToPoint:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    [self.bezierPath addLineToPoint:[touch locationInView:self]];
    
    // update the view
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


#pragma mark - Actions

- (void)clear
{
    [self.bufferArray removeAllObjects];
    [self.pathArray removeAllObjects];
    [self setNeedsDisplay];
}

- (UIImage *)image
{
    // create a snapshot
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // return the image
    return image;
}


#pragma mark - Undo / Redo

- (NSUInteger)undoSteps
{
    return self.bufferArray.count;
}

- (BOOL)canUndo
{
    return self.pathArray.count > 0;
}

- (void)undoLatestStep
{
    if ([self canUndo]) {
        UIColoredBezierPath *path = [self.pathArray lastObject];
        [self.bufferArray addObject:path];
        [self.pathArray removeLastObject];
        [self setNeedsDisplay];
    }
}

- (BOOL)canRedo
{
    return self.bufferArray.count > 0;
}

- (void)redoLatestStep
{
    if ([self canRedo]) {
        UIColoredBezierPath *path = [self.bufferArray lastObject];
        [self.pathArray addObject:path];
        [self.bufferArray removeLastObject];
        [self setNeedsDisplay];
    }
}

@end
