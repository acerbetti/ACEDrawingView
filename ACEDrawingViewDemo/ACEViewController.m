//
//  ACEViewController.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACEDrawingView.h"

#import <QuartzCore/QuartzCore.h>

@interface ACEViewController ()

@end

@implementation ACEViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start with red
    self.drawingView.lineColor = [UIColor redColor];
    self.lineWidthSlider.value = self.drawingView.lineWidth;
    
    // init the preview image
    self.previewImageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.previewImageView.layer.borderWidth = 2.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)takeScreenshot:(id)sender
{
    // show the preview image
    self.previewImageView.image = self.drawingView.image;
    self.previewImageView.hidden = NO;
    
    // close it after 3 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
        self.previewImageView.hidden = YES;
    });
}

- (IBAction)undo:(id)sender
{
    [self.drawingView undoLatestStep];
}

- (IBAction)redo:(id)sender
{
    [self.drawingView redoLatestStep];
}

- (IBAction)clear:(id)sender
{
    [self.drawingView clear];
}


#pragma mark - Settings

- (IBAction)colorChange:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.drawingView.lineColor = [UIColor redColor];
            break;
            
        case 1:
            self.drawingView.lineColor = [UIColor greenColor];
            break;
            
        case 2:
            self.drawingView.lineColor = [UIColor blueColor];
            break;
            
        default:
            self.drawingView.lineColor = [UIColor blackColor];
            break;
    }
}

- (IBAction)toggleWidthSlider:(id)sender
{
    // toggle the slider
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
    self.lineAlphaSlider.hidden = YES;
}


- (IBAction)widthChange:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
}

- (IBAction)toggleAlphaSlider:(id)sender
{
    // toggle the slider
    self.lineAlphaSlider.hidden = !self.lineAlphaSlider.hidden;
    self.lineWidthSlider.hidden = YES;
}

- (IBAction)alphaChange:(UISlider *)sender
{
    self.drawingView.lineAlpha = sender.value;
}

@end
