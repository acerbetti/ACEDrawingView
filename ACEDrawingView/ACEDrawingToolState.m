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

#import "ACEDrawingToolState.h"

@interface ACEDrawingToolState ()
@property (nonatomic, strong) id<ACEDrawingTool> tool;
@property (nonatomic, strong) id positionObject;
@end

@implementation ACEDrawingToolState

+ (instancetype)stateForTool:(id<ACEDrawingTool>)tool
{
    return [ACEDrawingToolState stateForTool:tool capturePosition:NO];
}

+ (instancetype)stateForTool:(id<ACEDrawingTool>)tool capturePosition:(BOOL)capture
{
    ACEDrawingToolState *state = [ACEDrawingToolState new];
    state.tool = tool;
    
    if (capture && [tool respondsToSelector:@selector(capturePositionObject)]) {
        state.positionObject = [tool capturePositionObject];
    }
    
    return state;
}

- (BOOL)hasPositionObject
{
    return self.positionObject != nil;
}

@end
