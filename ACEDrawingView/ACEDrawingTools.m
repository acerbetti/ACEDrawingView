/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ACEDrawingTools.h"
#import "ACEDrawingView.h"
#import "ACEDrawingToolState.h"
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <CoreText/CoreText.h>
#else
#import <AppKit/AppKit.h>
#endif

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark - ACEDrawingPenTool

@implementation ACEDrawingPenTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.lineCapStyle = kCGLineCapRound;
        path = CGPathCreateMutable();
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    //[self moveToPoint:firstPoint];
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    //[self addQuadCurveToPoint:midPoint(endPoint, startPoint) controlPoint:startPoint];
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint {
    
    CGPoint mid1 = midPoint(p1Point, p2Point);
    CGPoint mid2 = midPoint(cpoint, p1Point);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, p1Point.x, p1Point.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(path, NULL, subpath);
    CGPathRelease(subpath);
    
    return bounds;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextAddPath(context, path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, self.lineAlpha);
    CGContextStrokePath(context);
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

- (void)dealloc
{
    CGPathRelease(path);
    self.lineColor = nil;
    #if !ACE_HAS_ARC
    [super dealloc];
    #endif
}

@end


#pragma mark - ACEDrawingEraserTool

@implementation ACEDrawingEraserTool

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

	CGContextAddPath(context, path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

@end


#pragma mark - ACEDrawingLineTool

@interface ACEDrawingLineTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingLineTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    CGContextStrokePath(context);
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end

#pragma mark - ACEDrawingDraggableTextTool

@interface ACEDrawingDraggableTextTool ()
@property (nonatomic, strong) NSMutableArray *redoPositions;
@property (nonatomic, strong) NSMutableArray *undoPositions;
@end

#pragma mark -

@implementation ACEDrawingDraggableTextTool

@synthesize lineColor   = _lineColor;
@synthesize lineAlpha   = _lineAlpha;     // Not used for this tool
@synthesize lineWidth   = _lineWidth;     // Not used for this tool
@synthesize drawingView = _drawingView;
@synthesize labelView   = _labelView;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    CGRect frame = CGRectMake(firstPoint.x, firstPoint.y, 50, 100);
    
    _labelView = [[ACEDrawingLabelView alloc] initWithFrame:frame];
    _labelView.delegate     = self.drawingView;
    _labelView.fontSize     = 18.0;
    _labelView.fontName     = self.drawingView.draggableTextFontName ?: [UIFont systemFontOfSize:_labelView.fontSize].fontName;
    _labelView.textColor    = self.lineColor;
    _labelView.closeImage   = self.drawingView.draggableTextCloseImage;
    _labelView.rotateImage  = self.drawingView.draggableTextRotateImage;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    // Not used for this tool
}

- (void)draw
{
    if (self.labelView != nil && self.labelView.superview == nil) {
        [self.drawingView addSubview:self.labelView];
    }
}

- (void)applyToolState:(ACEDrawingToolState *)state
{    
    if (state.hasPositionObject) {
        [self applyTransform:state.positionObject];
    }
    
    [self draw];
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self capturePosition:YES];
}

- (id)capturePositionObject
{
    return [ACEDrawingLabelViewTransform transform:self.labelView.transform
                                          atCenter:self.labelView.center
                                        withBounds:self.labelView.bounds];
}

- (void)hideHandle
{
    [self.labelView hideEditingHandles];
}

- (NSMutableArray *)redoPositions
{
    if (!_redoPositions) {
        _redoPositions = [NSMutableArray new];
    }
    return _redoPositions;
}

- (NSMutableArray *)undoPositions
{
    if (!_undoPositions) {
        _undoPositions = [NSMutableArray new];
    }
    return _undoPositions;
}

- (void)applyTransform:(ACEDrawingLabelViewTransform *)t
{
    [UIView animateWithDuration:0.3 animations:^{
        self.labelView.center = t.center;
        self.labelView.transform = t.transform;
        self.labelView.bounds = t.bounds;
        [self.labelView resizeInRect:t.bounds];
    }];
}

- (void)capturePosition
{
    [self.undoPositions addObject:[ACEDrawingLabelViewTransform transform:self.labelView.transform
                                                                 atCenter:self.labelView.center
                                                               withBounds:self.labelView.bounds]];
    // clear redoPositions
    self.redoPositions = nil;
}

- (void)undraw
{
    [self.labelView removeFromSuperview];
}

- (BOOL)canRedo
{
    return self.redoPositions.count > 0 && self.labelView.superview;
}

- (BOOL)redo
{
    // add transform to undoPositions
    [self.undoPositions addObject:[ACEDrawingLabelViewTransform transform:self.labelView.transform
                                                                 atCenter:self.labelView.center
                                                               withBounds:self.labelView.bounds]];
    // apply transform
    ACEDrawingLabelViewTransform *t = [self.redoPositions lastObject];
    [self applyTransform:t];
    
    // remove transform from redoPositions
    [self.redoPositions removeLastObject];
    
    return ![self canRedo];
}

- (BOOL)canUndo
{
    return self.undoPositions.count > 0;
}

- (void)undo
{
    // add transform to redoPositions
    [self.redoPositions addObject:[ACEDrawingLabelViewTransform transform:self.labelView.transform
                                                                 atCenter:self.labelView.center
                                                               withBounds:self.labelView.bounds]];
    // apply transform
    ACEDrawingLabelViewTransform *t = [self.undoPositions lastObject];
    [self applyTransform:t];
    
    // remove transform from undoPositions
    [self.undoPositions removeLastObject];
}

@end

#pragma mark - ACEDrawingRectangleTool

@interface ACEDrawingRectangleTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingRectangleTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the rectangle
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end


#pragma mark - ACEDrawingEllipseTool

@interface ACEDrawingEllipseTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingEllipseTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the ellipse
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end

#pragma mark - ACEDrawingArrowTool

@interface ACEDrawingArrowTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

@implementation ACEDrawingArrowTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat capHeight = self.lineWidth * 4.0f;
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    
    // draw arrow cap
    CGFloat angle = [self angleWithFirstPoint:self.firstPoint secondPoint:self.lastPoint];
    CGPoint p1 = [self pointWithAngle:angle + 7.0f * M_PI / 8.0f distance:capHeight];
    CGPoint p2 = [self pointWithAngle:angle - 7.0f * M_PI / 8.0f distance:capHeight];
    CGPoint endPointOffset = [self pointWithAngle:angle distance:self.lineWidth];
    
    p1 = CGPointMake(self.lastPoint.x + p1.x, self.lastPoint.y + p1.y);
    p2 = CGPointMake(self.lastPoint.x + p2.x, self.lastPoint.y + p2.y);
    
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddLineToPoint(context, self.lastPoint.x + endPointOffset.x, self.lastPoint.y + endPointOffset.y);
    CGContextAddLineToPoint(context, p2.x, p2.y);
    
    CGContextStrokePath(context);
}

- (ACEDrawingToolState *)captureToolState
{
    return [ACEDrawingToolState stateForTool:self];
}

- (CGFloat)angleWithFirstPoint:(CGPoint)first secondPoint:(CGPoint)second
{
    CGFloat dx = second.x - first.x;
    CGFloat dy = second.y - first.y;
    CGFloat angle = atan2f(dy, dx);
    
    return angle;
}

- (CGPoint)pointWithAngle:(CGFloat)angle distance:(CGFloat)distance
{
    CGFloat x = distance * cosf(angle);
    CGFloat y = distance * sinf(angle);
    
    return CGPointMake(x, y);
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end
