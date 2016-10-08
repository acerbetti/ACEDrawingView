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

#import "ACEDrawingView.h"
#import "ACEDrawingTools.h"
#import "ACEDrawingToolState.h"

#import <QuartzCore/QuartzCore.h>

#define kDefaultLineColor       [UIColor blackColor]
#define kDefaultLineWidth       10.0f;
#define kDefaultLineAlpha       1.0f

// experimental code
#define PARTIAL_REDRAW          0
#define IOS8_OR_ABOVE [[[UIDevice currentDevice] systemVersion] integerValue] >= 8.0

@interface ACEDrawingView ()
{
    CGPoint currentPoint;
    CGPoint previousPoint1;
    CGPoint previousPoint2;
}

@property (nonatomic, strong) NSMutableArray *pathArray;

@property (nonatomic, strong) NSMutableArray *redoStates;
@property (nonatomic, strong) NSMutableArray *undoStates;

@property (nonatomic, strong) id<ACEDrawingTool> currentTool;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ACEDrawingLabelView *draggableTextView;
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
    
    self.redoStates = [NSMutableArray array];
    self.undoStates = [NSMutableArray array];
    
    // set the default values for the public properties
    self.lineColor = kDefaultLineColor;
    self.lineWidth = kDefaultLineWidth;
    self.lineAlpha = kDefaultLineAlpha;

    self.drawMode = ACEDrawingModeOriginalSize;
    
    // set the transparent background
    self.backgroundColor = [UIColor clearColor];
    
    // set the deafault draggable text icons
    NSURL *bundleURL = [[NSBundle bundleForClass:self.classForCoder] URLForResource:@"ACEDraggableText" withExtension:@"bundle"];
    self.draggableTextRotateImage = [UIImage imageWithContentsOfFile:[[NSBundle bundleWithURL:bundleURL] pathForResource:@"sticker_resize" ofType:@"png"]];
    self.draggableTextCloseImage  = [UIImage imageWithContentsOfFile:[[NSBundle bundleWithURL:bundleURL] pathForResource:@"sticker_close" ofType:@"png"]];
}

- (UIImage *)prev_image {
    return self.backgroundImage;
}

- (void)setPrev_image:(UIImage *)prev_image {
    [self setBackgroundImage:prev_image];
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
#if PARTIAL_REDRAW
    // TODO: draw only the updated part of the image
    [self drawPath];
#else
    switch (self.drawMode) {
        case ACEDrawingModeOriginalSize:
            [self.image drawAtPoint:CGPointZero];
            break;
            
        case ACEDrawingModeScale:
            [self.image drawInRect:self.bounds];
            break;
    }
    [self.currentTool draw];
#endif
}

- (void)commitAndDiscardToolStack
{
    [self updateCacheImage:YES];
    self.backgroundImage = self.image;
    [self.pathArray removeAllObjects];
}

- (void)updateCacheImage:(BOOL)redraw
{
    // init a context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    
    if (redraw) {
        // erase the previous image
        self.image = nil;
        
        // load previous image (if returning to screen)
        
        switch (self.drawMode) {
            case ACEDrawingModeOriginalSize:
                [[self.backgroundImage copy] drawAtPoint:CGPointZero];
                break;
            case ACEDrawingModeScale:
                [[self.backgroundImage copy] drawInRect:self.bounds];
                break;
        }
        
        // I need to redraw all the lines
        for (id<ACEDrawingTool> tool in self.pathArray) {
            [tool draw];
        }
        
    } else {
        // set the draw point
        [self.image drawAtPoint:CGPointZero];
        [self.currentTool draw];
    }
    
    // store the image
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)finishDrawing
{
    // update the image
    [self updateCacheImage:NO];
    
    // clear the redo queue
    [self.redoStates removeAllObjects];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawUsingTool:)]) {
        [self.delegate drawingView:self didEndDrawUsingTool:self.currentTool];
    }
    
    // clear the current tool
    self.currentTool = nil;
}

- (void)setCustomDrawTool:(id<ACEDrawingTool>)customDrawTool
{
    _customDrawTool = customDrawTool;
    
    if (customDrawTool != nil) {
        self.drawTool = ACEDrawingToolTypeCustom;
    }
}

- (id<ACEDrawingTool>)toolWithCurrentSettings
{
    switch (self.drawTool) {
        case ACEDrawingToolTypePen:
        {
            return ACE_AUTORELEASE([ACEDrawingPenTool new]);
        }
            
        case ACEDrawingToolTypeLine:
        {
            return ACE_AUTORELEASE([ACEDrawingLineTool new]);
        }
            
        case ACEDrawingToolTypeArrow:
        {
            return ACE_AUTORELEASE([ACEDrawingArrowTool new]);
        }
            
        case ACEDrawingToolTypeDraggableText:
        {
            ACEDrawingDraggableTextTool *tool = ACE_AUTORELEASE([ACEDrawingDraggableTextTool new]);
            tool.drawingView = self;
            return tool;
        }

        case ACEDrawingToolTypeRectagleStroke:
        {
            ACEDrawingRectangleTool *tool = ACE_AUTORELEASE([ACEDrawingRectangleTool new]);
            tool.fill = NO;
            return tool;
        }
            
        case ACEDrawingToolTypeRectagleFill:
        {
            ACEDrawingRectangleTool *tool = ACE_AUTORELEASE([ACEDrawingRectangleTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeEllipseStroke:
        {
            ACEDrawingEllipseTool *tool = ACE_AUTORELEASE([ACEDrawingEllipseTool new]);
            tool.fill = NO;
            return tool;
        }
            
        case ACEDrawingToolTypeEllipseFill:
        {
            ACEDrawingEllipseTool *tool = ACE_AUTORELEASE([ACEDrawingEllipseTool new]);
            tool.fill = YES;
            return tool;
        }
            
        case ACEDrawingToolTypeEraser:
        {
            return ACE_AUTORELEASE([ACEDrawingEraserTool new]);
        }
            
        case ACEDrawingToolTypeCustom:
        {
            return self.customDrawTool;
        }
    }
}


#pragma mark - Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.draggableTextView.isEditing && self.drawTool != ACEDrawingToolTypeDraggableText) {
        [self.draggableTextView hideEditingHandles];
    }
    
    // add the first touch
    UITouch *touch = [touches anyObject];
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    // init the bezier path
    self.currentTool = [self toolWithCurrentSettings];
    self.currentTool.lineWidth = self.lineWidth;
    self.currentTool.lineColor = self.lineColor;
    self.currentTool.lineAlpha = self.lineAlpha;
    
    if (self.edgeSnapThreshold > 0 && [self.currentTool isKindOfClass:[ACEDrawingRectangleTool class]]) {
        [self snapCurrentPointToEdges];
    }
    
    // Handle special cases for tool types. The else case handles all the non-text drawing tools.
    // The draggable text tool is purposely left in for better code clarity, even though it does nothing.
    if ([self.currentTool class] == [ACEDrawingDraggableTextTool class]) {
        // do nothing
        
    } else {
        [self.pathArray addObject:self.currentTool];
        [self.undoStates addObject:[self.currentTool captureToolState]];
        
        [self.currentTool setInitialPoint:currentPoint];
    }
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:willBeginDrawUsingTool:)]) {
        [self.delegate drawingView:self willBeginDrawUsingTool:self.currentTool];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // save all the touches in the path
    UITouch *touch = [touches anyObject];
    
    previousPoint2 = previousPoint1;
    previousPoint1 = [touch previousLocationInView:self];
    currentPoint = [touch locationInView:self];
    
    if (self.edgeSnapThreshold > 0 && [self.currentTool isKindOfClass:[ACEDrawingRectangleTool class]]) {
        [self snapCurrentPointToEdges];
    }
    
    if ([self.currentTool isKindOfClass:[ACEDrawingPenTool class]]) {
        CGRect bounds = [(ACEDrawingPenTool*)self.currentTool addPathPreviousPreviousPoint:previousPoint2 withPreviousPoint:previousPoint1 withCurrentPoint:currentPoint];
        
        CGRect drawBox = bounds;
        drawBox.origin.x -= self.lineWidth * 2.0;
        drawBox.origin.y -= self.lineWidth * 2.0;
        drawBox.size.width += self.lineWidth * 4.0;
        drawBox.size.height += self.lineWidth * 4.0;
        
        [self setNeedsDisplayInRect:drawBox];
        
    } else if ([self.currentTool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
        return;
    
    } else {
        [self.currentTool moveFromPoint:previousPoint1 toPoint:currentPoint];
        [self setNeedsDisplay];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesMoved:touches withEvent:event];
    
    if ([self.currentTool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
        if (self.draggableTextView.isEditing) {
            [self.draggableTextView hideEditingHandles];
        } else {
            CGPoint point = [[touches anyObject] locationInView:self];
            [self.currentTool setInitialPoint:point];
            self.draggableTextView = ((ACEDrawingDraggableTextTool *)self.currentTool).labelView;
            
            [self.pathArray addObject:self.currentTool];
            
            [self finishDrawing];
        }
    } else {
        [self finishDrawing];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // make sure a point is recorded
    [self touchesEnded:touches withEvent:event];
}

- (void)snapCurrentPointToEdges
{
    int xMax = self.frame.size.width;
    int yMax = self.frame.size.height;
    
    if (currentPoint.x < self.edgeSnapThreshold) {
        currentPoint.x = 0;
        
    } else if (currentPoint.x > xMax - self.edgeSnapThreshold) {
        currentPoint.x = xMax;
    }
    
    if (currentPoint.y < self.edgeSnapThreshold) {
        currentPoint.y = 0;
        
    } else if (currentPoint.y > yMax - self.edgeSnapThreshold) {
        currentPoint.y = yMax;
    }
}

#pragma mark - Load Image

- (void)loadImage:(UIImage *)image
{
    self.image = image;
    
    //save the loaded image to persist after an undo step
    self.backgroundImage = [image copy];
    
    // when loading an external image, I'm cleaning all the paths and the undo buffer
    [self.redoStates removeAllObjects];
    [self.undoStates removeAllObjects];
    [self.pathArray removeAllObjects];
    [self updateCacheImage:YES];
    [self setNeedsDisplay];
}

- (void)loadImageData:(NSData *)imageData
{
    CGFloat imageScale;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        imageScale = [[UIScreen mainScreen] scale];
        
    } else {
        imageScale = 1.0;
    }
    
    UIImage *image = [UIImage imageWithData:imageData scale:imageScale];
    [self loadImage:image];
}

- (void)resetTool
{
    self.currentTool = nil;
}

#pragma mark - Actions

- (void)clear
{
    [self resetTool];
    
    for (id<ACEDrawingTool> tool in self.pathArray) {
        if ([tool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
            [(ACEDrawingDraggableTextTool *)tool undraw];
        }
    }
    
    [self.redoStates removeAllObjects];
    [self.undoStates removeAllObjects];
    [self.pathArray removeAllObjects];
    self.backgroundImage = nil;
    [self updateCacheImage:YES];
    [self setNeedsDisplay];
}

- (void)prepareForSnapshot
{
    // make sure text label border and handles are hidden for snapshot
    [self hideTextToolHandles];
}

- (void)hideTextToolHandles
{
    for (id<ACEDrawingTool> tool in self.pathArray) {
        if ([tool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
            [(ACEDrawingDraggableTextTool *)tool hideHandle];
        }
    }
}

#pragma mark - Undo / Redo

- (BOOL)canUndo
{
    return self.undoStates.count > 0;
}

- (void)undoLatestStep
{
    if ([self canUndo]) {
        ACEDrawingToolState *undoState = [self.undoStates lastObject];
        
        // add to redo states
        [self.redoStates addObject:undoState];
        [self.redoStates addObject:[undoState.tool captureToolState]];
        
        // undo for tools last state
        if ([self lastStateForTool:undoState.tool inStateArray:self.undoStates]) {
            if ([undoState.tool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
                [(ACEDrawingDraggableTextTool *)undoState.tool undraw];
            }
            
            [self.pathArray enumerateObjectsUsingBlock:^(id<ACEDrawingTool> tool, NSUInteger idx, BOOL *stop) {
                if (tool == undoState.tool) {
                    [self.pathArray removeObjectAtIndex:idx];
                }
            }];
            
            [self.undoStates removeLastObject];
            
        // undo for a tools sub states
        } else {
            [self.undoStates removeLastObject];
            if ([undoState.tool respondsToSelector:@selector(applyToolState:)]) {
                [undoState.tool applyToolState:undoState];
            }
        }
        
        // redraw
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
        
        // call the delegate
        if ([self.delegate respondsToSelector:@selector(drawingView:didUndoDrawUsingTool:)]) {
            [self.delegate drawingView:self didUndoDrawUsingTool:undoState.tool];
        }
    }
}

- (BOOL)canRedo
{
    return self.redoStates.count > 0;
}

- (void)redoLatestStep
{
    if ([self canRedo]) {
        ACEDrawingToolState *redoState = [self.redoStates lastObject];
        
        if ([self lastStateForTool:redoState.tool inStateArray:self.redoStates]) {
            [self.pathArray addObject:redoState.tool];
        }
        
        [self.redoStates removeLastObject];
        if ([redoState.tool respondsToSelector:@selector(applyToolState:)]) {
            [redoState.tool applyToolState:redoState];
        }
        
        // update undo states
        [self.undoStates addObject:[self.redoStates lastObject]];
        [self.redoStates removeLastObject];
        
        // redraw
        [self updateCacheImage:YES];
        [self setNeedsDisplay];
        
        // call the delegate
        if ([self.delegate respondsToSelector:@selector(drawingView:didRedoDrawUsingTool:)]) {
            [self.delegate drawingView:self didRedoDrawUsingTool:redoState.tool];
        }
    }
}

- (BOOL)lastStateForTool:(id<ACEDrawingTool>)tool inStateArray:(NSArray *)stateArray
{
    NSInteger numberOfStates = 0;
    for (ACEDrawingToolState *state in stateArray) {
        if (state.tool == tool) { numberOfStates++; };
    }
    
    NSAssert(numberOfStates != 0, @"There much be atleast one state with a matching tool");
    
    return (stateArray == self.undoStates) ? numberOfStates == 1 : numberOfStates == 2;
}

- (void)dealloc
{
    self.pathArray = nil;
    self.redoStates = nil;
    self.undoStates = nil;
    self.currentTool = nil;
    self.image = nil;
    self.backgroundImage = nil;
    self.customDrawTool = nil;
    
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

#pragma mark - ACEDrawingLabelViewDelegate

- (void)labelViewDidClose:(ACEDrawingLabelView *)label
{
    ACEDrawingDraggableTextTool *tool = [self draggableTextToolForLabel:label];
    
    // TODO: handle close for adding redo state on close
    [self.pathArray removeObject:tool];
    
    // call the delegate
    if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawUsingTool:)]) {
        [self.delegate drawingView:self didEndDrawUsingTool:self.currentTool];
    }
}

- (void)labelViewDidBeginEditing:(ACEDrawingLabelView *)label
{
    ACEDrawingDraggableTextTool *tool = [self draggableTextToolForLabel:label];
    
    if (tool) { [self.undoStates addObject:[tool captureToolState]]; }
}

- (void)labelViewWillShowEditingHandles:(ACEDrawingLabelView *)label
{
    // make sure all text tool handles are hidden before we show the next one
    [self hideTextToolHandles];
}

- (void)labelViewDidShowEditingHandles:(ACEDrawingLabelView *)label
{
    self.draggableTextView = label;    
}

- (void)labelViewDidHideEditingHandles:(ACEDrawingLabelView *)label
{
    ACEDrawingDraggableTextTool *tool = [self draggableTextToolForLabel:label];
    
    if (![tool.labelView.textValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
        [self.pathArray removeObject:tool];
    }
    
    // if there are no undo states for the current tool, then we need to capture the first state
    NSInteger numberOfStates = 0;
    for (ACEDrawingToolState *state in self.undoStates) {
        if (state.tool == tool) {
            numberOfStates++;
        }
    }
    
    if (numberOfStates == 0 && tool) {
        [self.undoStates addObject:[tool captureToolState]];
        
        // call the delegate
        if ([self.delegate respondsToSelector:@selector(drawingView:didEndDrawUsingTool:)]) {
            [self.delegate drawingView:self didEndDrawUsingTool:tool];
        }
    }
}

- (ACEDrawingDraggableTextTool *)draggableTextToolForLabel:(ACEDrawingLabelView *)label
{
    for (id<ACEDrawingTool> tool in self.pathArray) {
        if ([tool isKindOfClass:[ACEDrawingDraggableTextTool class]]) {
            ACEDrawingDraggableTextTool *textTool = tool;
            if (textTool.labelView == label) { return textTool; }
        }
    }
    
    return nil;
}

@end
