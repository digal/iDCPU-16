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
        NSArray *tokens = [line componentsSeparatedByString:@" "];
        NSString *cmd = [tokens objectAtIndex:0];
        if ([cmd isEqualToString:@"FONT"]) {
            NSLog(@"Parsing font %@", [tokens objectAtIndex:1]);
        } else if ([cmd isEqualToString:@"ENCODING"]) {
            currentChar = [[tokens objectAtIndex:1] intValue];
//            NSLog(@"Current char: %c", currentChar);
        } else if ([cmd isEqualToString:@"BITMAP"]) {
            bitmapMode = true;
        } else if ([cmd isEqualToString:@"ENDCHAR"]) {
            font[currentChar * 2] = (currentGlyph >> 16) & 0xffff;
            font[(currentChar * 2)+1] = (currentGlyph) & 0xffff;
            bitmapMode = false;
            currentChar = -1;
            currentGlyph = 0;
            currentRow = 0;
        } else if (bitmapMode && currentChar >= 0) {
            char * pEnd;
            const char * cLine = [cmd cStringUsingEncoding:NSASCIIStringEncoding];
            UInt8 l = strtol(cLine, &pEnd, 16);
            l >>= 4;
            for (int col=0; col<4; col++) {
                UInt32 bit = (l >> 3-col) & 0x1;
                currentGlyph = currentGlyph | ((bit << ((3-col) * 8)) << (currentRow) );
            }
            currentRow ++;
        }
            
        
    }


}


@end
