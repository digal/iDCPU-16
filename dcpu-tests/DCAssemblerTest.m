//
//  DCAssemblerTest.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/22/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCAssemblerParser.h"
#import <GHUnitIOS/GHUnit.h> 

@interface DCAssemblerTest : GHTestCase

@end


@implementation DCAssemblerTest

- (void) testSimple {
    NSString* source = @":label SET A, 0x1234 ;comment";
    
    DCProgram* prog = [[DCAssemblerParser sharedParser] parseProgram:source];
}


- (void) testParser {
    NSString* fileRoot = [[NSBundle mainBundle] 
                          pathForResource:@"test" ofType:@"dasm"];
    
    NSString* source = [NSString stringWithContentsOfFile:fileRoot 
                                                   encoding:NSUTF8StringEncoding error:nil];
    
    DCProgram* prog = [[DCAssemblerParser sharedParser] parseProgram:source];
}

@end
