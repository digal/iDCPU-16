//
//  DCBDFParser.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/17/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMemory.h"

@interface DCBDFParser : NSObject {
    @public
    UInt16 font[VMEM_FONT_SIZE];
    
    @private
    int currentLine;
    int currentRow;
    char currentChar;
    UInt32 currentGlyph;
    BOOL bitmapMode;
}

- (BOOL) loadBDFFromFile:(NSString*)fileName;

@end
