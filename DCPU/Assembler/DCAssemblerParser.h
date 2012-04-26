//
//  DCAssemblerParser.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/22/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCProgram.h"
#import "ParseKit.h"

@interface DCAssemblerParser : NSObject {
    @private 
    NSString* _grammar;
    int _index;
    DCProgram* _program;
}

+ (DCAssemblerParser *)sharedParser;  // <= where Foo is the class name

- (DCProgram*) parseProgram:(NSString*)source;


@end
