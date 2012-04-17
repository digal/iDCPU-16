//
//  DCBDFParser.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/17/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCBDFParser.h"


@implementation DCBDFParser

- (id)init {
    self = [super init];
    if (self) {
        currentChar = -1;
        currentGlyph = 0;
        bitmapMode = false;
        
    }
    return self;
}

- (BOOL)loadBDFFromFile:(NSString *)fileName {
    NSString* fileRoot = [[NSBundle mainBundle] 
                          pathForResource:fileName ofType:@"bdf"];
    
    NSString* fileContents = 
        [NSString stringWithContentsOfFile:fileRoot 
                                  encoding:NSUTF8StringEncoding error:nil];
    
    NSArray* lines = [fileContents componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
//        NSLog(line, nil);
        NSArray *tokens = [line componentsSeparatedByString:@" "];
        NSString *cmd = [tokens objectAtIndex:0];
        if ([cmd isEqualToString:@"FONT"]) {
            NSLog(@"Parsing font %@", [tokens objectAtIndex:1]);
        } else if ([cmd isEqualToString:@"STARTCHAR"]) {
            NSString* charId = [tokens objectAtIndex:1];
            unichar c;
            if ([charId isEqualToString:@"C040"]) { //assume it's a space
                c = ' ';
            } else if (charId.length == 1)  {
                c = [charId characterAtIndex:0];
            } else {
                continue;
            }
            currentChar = c;
            NSLog(@"Current char: %c", currentChar);
        } else if ([cmd isEqualToString:@"BITMAP"]) {
            bitmapMode = true;
        } else if ([cmd isEqualToString:@"ENDCHAR"]) {
            bitmapMode = false;
            currentChar = -1;
        } else if (bitmapMode) {
            char * pEnd;
            const char * cLine = [cmd cStringUsingEncoding:NSASCIIStringEncoding];
            UInt32 l = strtol(cLine, &pEnd, 16);
            NSLog(@"line: 0x%02lx, cLine %s", l, cLine);
        }
            
        
    }


}


@end
