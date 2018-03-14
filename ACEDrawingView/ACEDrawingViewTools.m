//
//  ACEDrawingViewTools.m
//  ACEDrawingView
//
//  Created by Stefano Acerbetti on 3/14/18.
//

#import "ACEDrawingViewTools.h"

// drawable tools
#import "ACEDrawingViewToolArrow.h"
#import "ACEDrawingViewToolEllipse.h"
#import "ACEDrawingViewToolEraser.h"
#import "ACEDrawingViewToolLine.h"
#import "ACEDrawingViewToolPen.h"
#import "ACEDrawingViewToolRectangle.h"

@implementation ACEDrawingViewTools

+ (void)initialize
{
    // add the default tools
    [self registerToolClass:[ACEDrawingViewToolArrow class]];
    [self registerToolClass:[ACEDrawingViewToolEllipse class]];
    [self registerToolClass:[ACEDrawingViewToolEraser class]];
    [self registerToolClass:[ACEDrawingViewToolLine class]];
    [self registerToolClass:[ACEDrawingViewToolPen class]];
    [self registerToolClass:[ACEDrawingViewToolRectangle class]];
}

+ (NSMutableDictionary *)tools
{
    static NSMutableDictionary *_tools = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _tools = [NSMutableDictionary new];
    });
    return _tools;
}

+ (void)registerToolClass:(Class<ACEDrawingViewTool>)toolClass
{
    NSParameterAssert(toolClass != nil);
    
    [[self tools] setObject:toolClass forKey:[toolClass identifier]];
}

+ (id<ACEDrawingViewTool>)toolWithIdentifier:(NSString *)identifier
{
    NSParameterAssert(identifier != nil);
    
    Class toolClass = [[self tools] objectForKey:identifier];
    if (toolClass != nil) {
        return [toolClass init];
    }
    return nil;
}

@end
