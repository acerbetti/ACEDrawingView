//
//  ACEViewController.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 1/6/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEViewController.h"
#import "ACEDrawingView.h"

@interface ACEViewController ()

@end

@implementation ACEViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start with red
    self.drawingView.lineColor = [UIColor redColor];
    self.lineWidthSlider.value = self.drawingView.lineWidth;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)takeScreenshot:(id)sender
{
    [self.drawingView image];
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

- (IBAction)toggleWidthSlider:(id)sender
{
    // toggle the slider
    self.lineWidthSlider.hidden = !self.lineWidthSlider.hidden;
}

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

- (IBAction)widthChange:(UISlider *)sender
{
    self.drawingView.lineWidth = sender.value;
}

@end
