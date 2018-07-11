/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2016 Matthew Jackson
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

#import "ACEDrawingLabelView.h"

CG_INLINE CGPoint CGRectGetCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale)
{
    return CGRectMake(rect.origin.x * wScale, rect.origin.y * hScale, rect.size.width * wScale, rect.size.height * hScale);
}

CG_INLINE CGFloat CGPointGetDistance(CGPoint point1, CGPoint point2)
{
    CGFloat fx = (point2.x - point1.x);
    CGFloat fy = (point2.y - point1.y);
    
    return sqrt((fx*fx + fy*fy));
}

CG_INLINE CGFloat CGAffineTransformGetAngle(CGAffineTransform t)
{
    return atan2(t.b, t.a);
}


CG_INLINE CGSize CGAffineTransformGetScale(CGAffineTransform t)
{
    return CGSizeMake(sqrt(t.a * t.a + t.c * t.c), sqrt(t.b * t.b + t.d * t.d)) ;
}

@interface ACEDrawingLabelView () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, assign) CGRect initialBounds;
@property (nonatomic, assign) CGFloat initialDistance;

@property (nonatomic, assign) CGPoint beginningPoint;
@property (nonatomic, assign) CGPoint beginningCenter;

@property (nonatomic, assign) CGPoint touchLocation;

@property (nonatomic, assign) CGFloat deltaAngle;
@property (nonatomic, assign) CGRect beginBounds;

@property (nonatomic, assign) CGSize globalInsets;
@property (nonatomic, strong) CAShapeLayer *border;
@property (nonatomic, strong) UITextField *labelTextField;
@property (nonatomic, strong) UIButton *rotateButton;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, assign, getter=isShowingEditingHandles) BOOL showEditingHandles;

@end

@implementation ACEDrawingLabelView

- (void)refresh
{
    if (self.superview) {
        CGSize scale = CGAffineTransformGetScale(self.superview.transform);
        CGAffineTransform t = CGAffineTransformMakeScale(scale.width, scale.height);
        [self.closeButton setTransform:CGAffineTransformInvert(t)];
        [self.rotateButton setTransform:CGAffineTransformInvert(t)];
        
        if (self.isShowingEditingHandles) {
            [self.labelTextField.layer addSublayer:self.border];
        } else {
            [self.border removeFromSuperlayer];
        }
    }
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self refresh];
}

- (void)setFrame:(CGRect)newFrame
{
    [super setFrame:newFrame];
    [self refresh];
}

- (id)initWithFrame:(CGRect)frame
{
    if (frame.size.width < 25)     frame.size.width = 25;
    if (frame.size.height < 25)    frame.size.height = 25;
    
    self = [super initWithFrame:frame];
    if (self) {
        self.labelTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.border = [CAShapeLayer layer];

        _globalInsets = CGSizeMake(12, 12);
        _closeButtonOffset = CGPointZero;
        _rotateButtonOffset = CGPointZero;
        _closeButtonSize = CGSizeMake(24, 24);
        _rotateButtonSize = CGSizeMake(24, 24);
        _shadowColor = [UIColor blackColor];
        _shadowOffset = CGSizeMake(0, 5);
        _shadowOpacity = 1;
        _shadowRadius = 4;
        
        self.backgroundColor = [UIColor clearColor];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        self.borderColor = [UIColor redColor];

        [self.labelTextField setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [self.labelTextField setClipsToBounds:YES];
        self.labelTextField.delegate = self;
        self.labelTextField.backgroundColor = [UIColor clearColor];
        self.labelTextField.tintColor = [UIColor redColor];
        self.labelTextField.textColor = [UIColor whiteColor];
        self.labelTextField.text = @"";
        [self.labelTextField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];

        self.border.strokeColor = self.borderColor.CGColor;
        self.border.fillColor = nil;
        self.border.lineDashPattern = @[@4, @3];
        
        [self insertSubview:self.labelTextField atIndex:0];
        
        self.closeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.closeButton setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin)];
        self.closeButton.backgroundColor = [UIColor whiteColor];
        self.closeButton.layer.cornerRadius = self.globalInsets.width - 5;
        self.closeButton.userInteractionEnabled = YES;
        [self addSubview:self.closeButton];
        
        self.rotateButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.rotateButton setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin)];
        self.rotateButton.backgroundColor = [UIColor whiteColor];
        self.rotateButton.layer.cornerRadius = self.globalInsets.width - 5;
        self.rotateButton.contentMode = UIViewContentModeCenter;
        self.rotateButton.userInteractionEnabled = YES;
        [self addSubview:self.rotateButton];

        [self applyLayout];
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
        [self addGestureRecognizer:moveGesture];
        
        UITapGestureRecognizer *singleTapShowHide = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapped:)];
        [self addGestureRecognizer:singleTapShowHide];
        
        UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeTap:)];
        [self.closeButton addGestureRecognizer:closeTap];
        
        UIPanGestureRecognizer *panRotateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotateViewPanGesture:)];
        [self.rotateButton addGestureRecognizer:panRotateGesture];

        [moveGesture requireGestureRecognizerToFail:closeTap];
        
        [self setEnableMoveRestriction:NO];
        [self setEnableClose:YES];
        [self setEnableRotate:YES];
        [self setShowsContentShadow:YES];
        
        [self showEditingHandles];
    }
    return self;
}

- (void)layoutSubviews
{
    if (self.labelTextField) {
        self.border.path = [UIBezierPath bezierPathWithRect:self.labelTextField.bounds].CGPath;
        self.border.frame = self.labelTextField.bounds;
    }
}

- (void)beginEditing
{
    [self.labelTextField becomeFirstResponder];
}

- (void)applyLayout
{
    _labelTextField.frame = CGRectInset(self.bounds, self.globalInsets.width, self.globalInsets.height);
    _closeButton.frame = CGRectMake(self.closeButtonOffset.x, self.closeButtonOffset.y, self.closeButtonSize.width, self.closeButtonSize.height);
    _rotateButton.frame = CGRectMake(
                                     self.bounds.size.width - self.rotateButtonSize.width + self.rotateButtonOffset.x,
                                     self.bounds.size.height - self.rotateButtonSize.height + self.rotateButtonOffset.y,
                                     self.rotateButtonSize.width,
                                     self.rotateButtonSize.height);
}

- (void)updateShadow
{
    if (_showsContentShadow) {
        [self.layer setShadowColor:self.shadowColor.CGColor];
        [self.layer setShadowOffset:self.shadowOffset];
        [self.layer setShadowOpacity:self.shadowOpacity];
        [self.layer setShadowRadius:self.shadowRadius];
    } else {
        [self.layer setShadowColor:[UIColor clearColor].CGColor];
        [self.layer setShadowOffset:CGSizeZero];
        [self.layer setShadowOpacity:0.0];
        [self.layer setShadowRadius:0.0];
    }
}

#pragma mark - Set Control Buttons

- (void)setEnableClose:(BOOL)value
{
    _enableClose = value;
    [self.closeButton setHidden:!_enableClose];
    [self.closeButton setUserInteractionEnabled:_enableClose];
}

- (void)setEnableRotate:(BOOL)value
{
    _enableRotate = value;
    [self.rotateButton setHidden:!_enableRotate];
    [self.rotateButton setUserInteractionEnabled:_enableRotate];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self updateShadow];
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    _shadowOffset = shadowOffset;
    [self updateShadow];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    _shadowOpacity = shadowOpacity;
    [self updateShadow];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    [self updateShadow];
}

- (void)setShowsContentShadow:(BOOL)showShadow
{
    _showsContentShadow = showShadow;
    [self updateShadow];
}

- (void)setCloseImage:(UIImage *)image
{
    _closeImage = image;
    [self.closeButton setImage:_closeImage forState:UIControlStateNormal];
}

- (void)setRotateImage:(UIImage *)image
{
    _rotateImage = image;
    [self.rotateButton setImage:_rotateImage forState:UIControlStateNormal];
    
}

#pragma mark - Set Text Field

- (void)setFontName:(NSString *)name
{
    if (name.length > 0) {
        _fontName = name;
        self.labelTextField.font = [UIFont fontWithName:_fontName size:self.fontSize];
        [self.labelTextField adjustsWidthToFillItsContents];
    }
}

- (void)setFontSize:(CGFloat)size
{
    _fontSize = size;
    self.labelTextField.font = [UIFont fontWithName:self.fontName size:_fontSize];
}

- (void)setTextColor:(UIColor *)color
{
    _textColor = color;
    self.labelTextField.textColor = _textColor;
}

- (void)setBorderColor:(UIColor *)color
{
    _borderColor = color;
    self.border.strokeColor = _borderColor.CGColor;
}

- (void)setTextAlpha:(CGFloat)alpha
{
    self.labelTextField.alpha = alpha;
}

- (CGFloat)textAlpha
{
    return self.labelTextField.alpha;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    [self.labelTextField setAttributedPlaceholder:attributedPlaceholder];
    [self.labelTextField adjustsWidthToFillItsContents];
}

#pragma mark - Bounds

- (void)hideEditingHandles
{
    self.showEditingHandles = NO;
    
    if (self.isEnableClose)       self.closeButton.hidden = YES;
    if (self.isEnableRotate)      self.rotateButton.hidden = YES;
    
    [self.labelTextField resignFirstResponder];
    
    [self refresh];
    
    if([self.delegate respondsToSelector:@selector(labelViewDidHideEditingHandles:)]) {
        [self.delegate labelViewDidHideEditingHandles:self];
    }
}

- (void)showEditingHandles
{
    if ([self.delegate respondsToSelector:@selector(labelViewWillShowEditingHandles:)]) {
        [self.delegate labelViewWillShowEditingHandles:self];
    }
    
    self.showEditingHandles = YES;
        
    if (self.isEnableClose)       self.closeButton.hidden = NO;
    if (self.isEnableRotate)      self.rotateButton.hidden = NO;
    
    [self refresh];
    
    if ([self.delegate respondsToSelector:@selector(labelViewDidShowEditingHandles:)]) {
        [self.delegate labelViewDidShowEditingHandles:self];
    }
}

- (void)resizeInRect:(CGRect)rect
{
    [self.labelTextField adjustsFontSizeToFillRect:rect];
}

#pragma mark - Gestures

- (void)contentTapped:(UITapGestureRecognizer*)tapGesture
{
    if (self.isShowingEditingHandles) {
        [self hideEditingHandles];
        [self.superview bringSubviewToFront:self];
    } else {
        [self showEditingHandles];
    }
}

- (void)closeTap:(UITapGestureRecognizer *)recognizer
{
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(labelViewDidClose:)]) {
        [self.delegate labelViewDidClose:self];
    }
}

- (void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!self.isShowingEditingHandles) {
        [self showEditingHandles];
    }
    self.touchLocation = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.beginningPoint = self.touchLocation;
        self.beginningCenter = self.center;
        
        [self setCenter:[self estimatedCenter]];
        self.beginBounds = self.bounds;
        
        if ([self.delegate respondsToSelector:@selector(labelViewDidBeginEditing:)]) {
            [self.delegate labelViewDidBeginEditing:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self setCenter:[self estimatedCenter]];
        
        if ([self.delegate respondsToSelector:@selector(labelViewDidChangeEditing:)]) {
            [self.delegate labelViewDidChangeEditing:self];
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self setCenter:[self estimatedCenter]];
        
        if ([self.delegate respondsToSelector:@selector(labelViewDidEndEditing:)]) {
            [self.delegate labelViewDidEndEditing:self];
        }
    }
}

- (CGPoint)estimatedCenter
{
    CGPoint newCenter;
    CGFloat newCenterX = self.beginningCenter.x + (self.touchLocation.x - self.beginningPoint.x);
    CGFloat newCenterY = self.beginningCenter.y + (self.touchLocation.y - self.beginningPoint.y);
    if (self.isEnableMoveRestriction) {
        if (!(newCenterX - 0.5 * CGRectGetWidth(self.frame) > 0 &&
              newCenterX + 0.5 * CGRectGetWidth(self.frame) < CGRectGetWidth(self.superview.bounds))) {
            newCenterX = self.center.x;
        }
        if (!(newCenterY - 0.5 * CGRectGetHeight(self.frame) > 0 &&
              newCenterY + 0.5 * CGRectGetHeight(self.frame) < CGRectGetHeight(self.superview.bounds))) {
            newCenterY = self.center.y;
        }
        newCenter = CGPointMake(newCenterX, newCenterY);
    } else {
        newCenter = CGPointMake(newCenterX, newCenterY);
    }
    return newCenter;
}

- (void)rotateViewPanGesture:(UIPanGestureRecognizer *)recognizer
{
    self.touchLocation = [recognizer locationInView:self.superview];
    
    CGPoint center = CGRectGetCenter(self.frame);
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        self.deltaAngle = atan2(self.touchLocation.y-center.y, self.touchLocation.x-center.x)-CGAffineTransformGetAngle(self.transform);
        
        self.initialBounds = self.bounds;
        self.initialDistance = CGPointGetDistance(center, self.touchLocation);
        
        if([self.delegate respondsToSelector:@selector(labelViewDidBeginEditing:)]) {
            [self.delegate labelViewDidBeginEditing:self];
        }
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        float ang = atan2(self.touchLocation.y-center.y, self.touchLocation.x-center.x);
        
        float angleDiff = self.deltaAngle - ang;
        [self setTransform:CGAffineTransformMakeRotation(-angleDiff)];
        [self setNeedsDisplay];
        
        //Finding scale between current touchPoint and previous touchPoint
        double scale = sqrtf(CGPointGetDistance(center, self.touchLocation)/self.initialDistance);
        
        CGRect scaleRect = CGRectScale(self.initialBounds, scale, scale);
        
        if (scaleRect.size.width >= (1+self.globalInsets.width*2 + 20) && scaleRect.size.height >= (1+self.globalInsets.height*2 + 20)) {
            if (self.fontSize < 100 || CGRectGetWidth(scaleRect) < CGRectGetWidth(self.bounds)) {
                CGRect boundsCheckRect = scaleRect;
                boundsCheckRect.size.width -= self.globalInsets.width * 2;
                [self.labelTextField adjustsFontSizeToFillRect:boundsCheckRect];
                [self setBounds:scaleRect];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(labelViewDidChangeEditing:)]) {
            [self.delegate labelViewDidChangeEditing:self];
        }
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(labelViewDidEndEditing:)]) {
            [self.delegate labelViewDidEndEditing:self];
        }
    }
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.isShowingEditingHandles) {
        return YES;
    }
    [self contentTapped:nil];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(labelViewDidStartEditing:)]) {
        [self.delegate labelViewDidStartEditing:self];
    }
    
    [textField adjustsWidthToFillItsContents];
}


#pragma mark - UITextField UIControlEvent
- (void)textFieldEditingChanged:(UITextField *)textField {
    if (!self.isShowingEditingHandles) {
        [self showEditingHandles];
    }
    [textField adjustsWidthToFillItsContents];
}


#pragma mark - Additional Properties

- (BOOL)isEditing
{
    return self.isShowingEditingHandles;
}

- (NSString *)textValue
{
    return self.labelTextField.text;
}

@end


#pragma mark - UITextField Category for DynamicFontSize

@implementation UITextField (DynamicFontSize)

static const NSUInteger ACELVMaximumFontSize = 101;
static const NSUInteger ACELVMinimumFontSize = 9;

- (void)adjustsFontSizeToFillRect:(CGRect)newBounds
{
    NSString *text = (![self.text isEqualToString:@""] || !self.placeholder) ? self.text : self.placeholder;
    
    for (NSUInteger i = ACELVMaximumFontSize; i > ACELVMinimumFontSize; i--) {
        UIFont *font = [UIFont fontWithName:self.font.fontName size:(CGFloat)i];
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                                             attributes:@{ NSFontAttributeName : font }];
        
        CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(CGRectGetWidth(newBounds), CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
        
        if (CGRectGetHeight(rectSize) <= CGRectGetHeight(newBounds)) {
            ((ACEDrawingLabelView *)self.superview).fontSize = (CGFloat)i-1;
            break;
        }
    }
}

- (void)adjustsWidthToFillItsContents
{
    NSString *text = (![self.text isEqualToString:@""] || !self.placeholder) ? self.text : self.placeholder;
    UIFont *font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize];
    // Hotfix: despite exact text measurement, label text ends up clipped either on the beginning or the end.
    // Inserting a couple extra characters here makes the end stick out awkwardly sometimes, but avoids the
    // issue if you rotate the text.
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[text stringByAppendingString:@"xx"]
                                                                         attributes:@{ NSFontAttributeName : font }];
    
    CGRect rectSize = [attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.frame)-24)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
    
    float w1 = (ceilf(rectSize.size.width) + 24 < 50) ? self.frame.size.width : ceilf(rectSize.size.width) + 24;
    float h1 =(ceilf(rectSize.size.height) + 24 < 50) ? 50 : ceilf(rectSize.size.height) + 24;
    
    CGRect viewFrame = self.superview.bounds;
    viewFrame.size.width = w1 + 24;
    viewFrame.size.height = h1;
    self.superview.bounds = viewFrame;
}

@end

#pragma mark - ACEDrawingLabelViewTransform

@interface ACEDrawingLabelViewTransform ()
@property (nonatomic, assign) CGAffineTransform transform;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGRect bounds;
@end

@implementation ACEDrawingLabelViewTransform

+ (instancetype)transform:(CGAffineTransform)transform atCenter:(CGPoint)center withBounds:(CGRect)bounds
{
    ACEDrawingLabelViewTransform *t = [ACEDrawingLabelViewTransform new];
    t.transform = transform;
    t.center = center;
    t.bounds = bounds;
    
    return t;
}

@end
