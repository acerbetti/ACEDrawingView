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

#import <UIKit/UIKit.h>

@protocol ACEDrawingLabelViewDelegate;

@interface ACEDrawingLabelView : UIView

/** 
 * Text Value
 */
@property (nonatomic, readonly) NSString *textValue;

/**
 * Text color.
 *
 * Default: white color.
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 * Border stroke color.
 *
 * Default: red color.
 */
@property (nonatomic, strong) UIColor *borderColor;

/**
 * Name of text field font.
 *
 * Default: current system font
 */
@property (nonatomic, copy) NSString *fontName;

/**
 * Size of text field font.
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 * Image for close button.
 *
 * Default:
 */
@property (nonatomic, strong) UIImage *closeImage;

/**
 * Image for rotation button.
 *
 * Default: 
 */
@property (nonatomic, strong) UIImage *rotateImage;

/**
 * Placeholder.
 *
 * Default: nil
 */
@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;

/*
 * Base delegate protocols.
 */
@property (nonatomic, weak) id <ACEDrawingLabelViewDelegate> delegate;

/**
 *  Shows content shadow.
 *
 *  Default: YES.
 */
@property (nonatomic) BOOL showsContentShadow;

/**
 *  Shows close button.
 *
 *  Default: YES.
 */
@property (nonatomic, getter=isEnableClose) BOOL enableClose;

/**
 *  Shows rotate/resize butoon.
 *
 *  Default: YES.
 */
@property (nonatomic, getter=isEnableRotate) BOOL enableRotate;

/**
 *  Resticts movements in superview bounds.
 *
 *  Default: NO.
 */
@property (nonatomic, getter=isEnableMoveRestriction) BOOL enableMoveRestriction;

/**
 *  Check if underlying textField is first responder
 */
@property (nonatomic, readonly) BOOL isEditing;

/**
 *  Hides border and control buttons.
 */
- (void)hideEditingHandles;

/**
 *  Shows border and control buttons.
 */
- (void)showEditingHandles;

/** Sets the text alpha.
 *
 * @param alpha     A value of text transparency.
 */
- (void)setTextAlpha:(CGFloat)alpha;

/** Returns text alpha.
 *
 * @return  A value of text transparency.
 */
- (CGFloat)textAlpha;

/**
 * Resizes content to fit rect
 */
- (void)resizeInRect:(CGRect)rect;

@end

@protocol ACEDrawingLabelViewDelegate <NSObject>

@optional

/**
 *  Occurs when a touch gesture event occurs on close button.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidClose:(ACEDrawingLabelView *)label;

/**
 *  Occurs before border and control buttons will show.
 *
 *  @param label    A label object informing the delegate about showing.
 */
- (void)labelViewWillShowEditingHandles:(ACEDrawingLabelView *)label;

/**
 *  Occurs when border and control buttons was shown.
 *
 *  @param label    A label object informing the delegate about showing.
 */
- (void)labelViewDidShowEditingHandles:(ACEDrawingLabelView *)label;

/**
 *  Occurs when border and control buttons was hidden.
 *
 *  @param label    A label object informing the delegate about hiding.
 */
- (void)labelViewDidHideEditingHandles:(ACEDrawingLabelView *)label;

/**
 *  Occurs when label become first responder.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidStartEditing:(ACEDrawingLabelView *)label;

/**
 *  Occurs when label starts move or rotate.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidBeginEditing:(ACEDrawingLabelView *)label;

/**
 *  Occurs when label continues move or rotate.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidChangeEditing:(ACEDrawingLabelView *)label;

/**
 *  Occurs when label ends move or rotate.
 *
 *  @param label    A label object informing the delegate about action.
 */
- (void)labelViewDidEndEditing:(ACEDrawingLabelView *)label;

@end

#pragma mark - UITextField Category for DynamicFontSize

@interface UITextField (DynamicFontSize)

/**
 *  Adjust font size to new bounds.
 *
 *  @param newBounds A new bounds.
 */
- (void)adjustsFontSizeToFillRect:(CGRect)newBounds;

/**
 *  Adjust width to new text.
 */
- (void)adjustsWidthToFillItsContents;

@end

#pragma mark - ACEDrawingLabelViewTransform

@interface ACEDrawingLabelViewTransform : NSObject

+ (instancetype)transform:(CGAffineTransform)transform atCenter:(CGPoint)center withBounds:(CGRect)bounds;

@property (nonatomic, readonly) CGAffineTransform transform;
@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;

@end
