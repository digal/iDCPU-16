//
//  DCViewController.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCViewController.h"
@interface DCViewController ()

@end

@implementation DCViewController
@synthesize scrollView;
@synthesize screen;
@synthesize dcpu;
@synthesize timer;

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    self.dcpu = [self createEmulator];
    self.screen = [[DCScreenViewController alloc] init];
    [self.screen handleEmulator:dcpu];
    NSLog(@"view: %@", screen.view);
    [self.scrollView addSubview:screen.view];
    screen.view.frame = CGRectMake(0, 0, 320, 256);
    
    [self runEmulator:dcpu withInterval:0.1];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self.timer invalidate];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) runEmulator:(DCEmulator*)emu withInterval:(NSTimeInterval)interval{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self.dcpu 
                                                selector:@selector(step)
                                                userInfo:@""
                                                 repeats:YES];
}

- (DCEmulator*) createEmulator {
    DCEmulator *dce = [[DCEmulator alloc] init];
    //set top-left char to 'A'
    dce->mem[VMEM_FONT_START + (0x41 * 2)] = 0x7E09;
    dce->mem[VMEM_FONT_START + (0x41 * 2)] = 0x7E00;
    dce->mem[VMEM_DISPLAY_START] = (UInt16)'A';
    
    UInt16 program[5] = {
        SET | PUSH << 4 | 0x30 << 10,         //SET PUSH 0x10
        SET | X    << 4 | POP <<  10,         //SET X POP
        ADD | NWP << 4  | 0x21 << 10, 0x1000, //ADD [0x1000] 1
        0x0 | JSR << 4  | 0x22 << 10          //JSR 0x2
    };
    
    [dce loadBinary:program withLength:5];
    
    return dce;
}



@end
