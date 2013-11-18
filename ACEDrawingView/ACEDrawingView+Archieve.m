//
//  ACEDrawingView+Archieve.m
//  ACEDrawingViewDemo
//
//  Created by Prashant Rane on 11/18/13.
//  Copyright (c) 2013 Stefano Acerbetti. All rights reserved.
//

#import "ACEDrawingView+Archieve.h"
#import "ACEDrawingView_Private.h"

static NSString* const kDefaultDrawingPath = @"drawing.png";

@implementation ACEDrawingView (Archieve)

- (void)saveDrawingAtPath:(NSString*)path
{
    if (path == nil || path.length < 1)
    {
        path = [self rootDirectoryPath:kDefaultDrawingPath];
    }
    [UIImagePNGRepresentation(self.image) writeToFile:path atomically:YES];
}

- (void)loadDrawingFromPath:(NSString*)path
{
    if (path == nil || path.length < 1)
    {
        path = [self rootDirectoryPath:kDefaultDrawingPath];
    }
    self.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
}

- (NSString *) rootDirectoryPath:(NSString *)rootDirectoryName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (rootDirectoryName)
    {
        return [paths[0] stringByAppendingPathComponent: rootDirectoryName];
    }
    return paths[0];
}

@end
