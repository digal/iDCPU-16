//
//  DCAssemblerParser.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/22/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCAssemblerParser.h"
#import <ParseKit/ParseKit.h>

//#define USE_TRACK 1

@implementation DCAssemblerParser

static DCAssemblerParser *instance = nil;

+ (DCAssemblerParser*) sharedParser {
    @synchronized(self) {
        if (!instance) {
            instance = [[DCAssemblerParser alloc] init];

            NSString* fileRoot = [[NSBundle mainBundle] 
                                  pathForResource:@"dasm" ofType:@"grammar"];
            
            instance->_grammar = [NSString stringWithContentsOfFile:fileRoot 
                                                           encoding:NSUTF8StringEncoding error:nil];
            
        }
        return instance;
    }
}


- (void)error:(NSString*)message onLine:(int)line {
    NSLog(@"%d: %@", line, message);
}

- (DCProgram*) parseProgram:(NSString*)source {
    PKParser *parser = [[PKParserFactory factory] parserFromGrammar:_grammar assembler:self];
    _program = [[DCProgram alloc] init];
    _index = 0;
    
    NSObject* a = [parser parse:source];
    NSLog(@"a: %@", a);
    PKReleaseSubparserTree(parser);
    
    return nil;
}

- (void)parser:(PKParser* )p didMatchBasicInstruction:(PKAssembly *)a {
    NSLog(@"didMatchBasicInstruction: %@", a);
    PKToken* op = [a pop];
    PKToken* arg1 = [a pop];
    PKToken* arg2 = [a pop];
    NSLog(@"%@ %@, %@", op, arg1, arg2);
    
}

- (void)parser:(PKParser* )p didMatchWInstruction:(PKAssembly *)a {
    NSLog(@"didMatchWInstruction: %@", a);
    PKToken* op = [a pop];
    PKToken* arg1 = [a pop];
    PKToken* arg2 = [a pop];
    NSLog(@"%@ %@, %@", op, arg1, arg2);
}

- (void)parser:(PKParser* )p didMatchLabel:(PKAssembly *)a {
    NSLog(@"didMatchLabel: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(PKParser* )p didMatchElement:(PKAssembly *)a {
    NSLog(@"didMatchElement: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(id)p didMatchAssembly:(PKAssembly *)a {
    NSLog(@"didMatchAssembly: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(PKParser* )p didMatchLabelName:(PKAssembly *)a {
    NSLog(@"didMatchLabelName: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(id)p didMatchROperand:(PKAssembly *)a {
    NSLog(@"didMatchROperand: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(id)p didMatchWOperand:(PKAssembly *)a {
    NSLog(@"didMatchWOperand: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(id)p didMatchRWOperand:(PKAssembly *)a {
    NSLog(@"didMatchRWOperand: %@", a);
    NSLog(@"%@", [a pop]);
}

- (void)parser:(id)p didMatchSetOp:(PKAssembly *)a {
    NSLog(@"didMatchSetOp: %@", a);
    PKToken *token = [a pop];
    NSLog(@"%@", token);
}



@end
