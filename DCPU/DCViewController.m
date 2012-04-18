//
//  DCViewController.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCViewController.h"
#import "DCBDFParser.h"
@interface DCViewController ()

@end

@implementation DCViewController
@synthesize scrollView;
@synthesize screen;
@synthesize dcpu;
@synthesize timer;
@synthesize editor;

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    self.dcpu = [self createEmulator];
    self.screen = [[DCScreenViewController alloc] init];
    self.editor = [[UITextView alloc] initWithFrame:CGRectMake(320, 0, 320, self.scrollView.frame.size.height)];
    self.editor.editable = YES;
    self.editor.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.screen handleEmulator:dcpu];
    NSLog(@"view: %@", screen.view);
    self.scrollView.contentSize = CGSizeMake(640, self.scrollView.contentSize.height);
    [self.scrollView addSubview:screen.view];
    [self.scrollView addSubview:editor];
    screen.view.frame = CGRectMake(16, 0, 288, 224);
    NSLog(@"editor: %@", editor);
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
    DCBDFParser *parser = [[DCBDFParser alloc] init];
    [parser loadBDFFromFile:@"atari-small"];
    
    DCEmulator *dce = [[DCEmulator alloc] init];
    memcpy(&(dce->mem[VMEM_FONT_START]), parser->font, VMEM_FONT_SIZE * sizeof(UInt16));
    
    dce->mem[VMEM_BG]     = 0xF; //white
    
    UInt16 program[] = {
        SET | X     << 4 | 0x2A  << 10,        //SET X, 11
        ADD | X     << 4 | NW    << 10, VMEM_DISPLAY_START + 32*6,     //ADD x, VMEM + 32 * 6 
        SET | Y     << 4 | 0x2D  << 10,     //SET Y, :data
        IFE | MEM_Y << 4 | 0x20  << 10,           //IFE [X], 20
        SET | PC    << 4 | 0x2C  << 10,           //JMP :loop
        SET | MEM_X << 4 | MEM_Y << 10,           //SET [Y], [X]
        BOR | MEM_X << 4 | NW    << 10,  0x0F00,  //BOR [Y], 0x0F00 ; set char color
        ADD | X     << 4 | 0x21  << 10,               //ADD X, 1
        ADD | Y     << 4 | 0x21  << 10,               //ADD Y, 1
        SET | PC    << 4 | 0x24  << 10,               //ADD Y, 1
        SET | PC    << 4 | 0x2C  << 10,               //JMP :loop
        'H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!', 0x0
    };
    
    [dce loadBinary:program withLength:sizeof(program) / sizeof(UInt16)];
    
    return dce;
}



@end
