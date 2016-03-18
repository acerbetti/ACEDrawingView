//
//  ACEDrawingViewTest.m
//  ACEDrawingViewDemo
//
//  Created by Stefano Acerbetti on 3/17/16.
//  Copyright © 2016 Stefano Acerbetti. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ACEDrawingTools.h"
#import "ACEDrawingView.h"

@interface ACEDrawingViewTest : XCTestCase
@property(nonatomic, strong) ACEDrawingView *drawingView;
@end

@implementation ACEDrawingViewTest

- (void)setUp
{
    [super setUp];
    
    self.drawingView = [[ACEDrawingView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
    self.drawingView = nil;
    [super tearDown];
}

- (void)testSetLineColor
{
    self.drawingView.lineColor = [UIColor orangeColor];
    
    ACEDrawingPenTool *tool = [[ACEDrawingPenTool alloc] init];
    self.drawingView.customDrawTool = tool;
    XCTAssertNil(tool.lineColor);
    
    // this will initialize the tool
    [self.drawingView touchesBegan:[NSSet set] withEvent:nil];
    XCTAssertEqualObjects(self.drawingView.lineColor, tool.lineColor);
}

@end
