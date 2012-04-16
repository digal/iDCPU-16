//
//  DCScreenViewController.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCScreenViewController.h"
@interface DCScreenViewController ()

@end

@implementation DCScreenViewController

@synthesize screenView;

- (id)init
{
    self = [super init];
    if (self) {
        self->_pixelMultiplier = 1;
        // Custom initialization
    }
    return self;
}

- (void)handleEmulator:(DCEmulator *)emulator {
    [emulator addHWHandler:^(DCEmulator* emu){
        NSLog(@"Emulator callback");
        memcpy(self.screenView->font, &(emu->mem[VMEM_FONT_START]), VMEM_FONT_SIZE * sizeof(UInt16));
        memcpy(self.screenView->chars, &(emu->mem[VMEM_DISPLAY_START]), VMEM_DISPLAY_SIZE * sizeof(UInt16));
        self.screenView->background = emu->mem[VMEM_BG]; 
        [self.screenView setNeedsDisplay];
    }   
                withPeriod:10 
                   andName:@"Display"];
    
}

- (void)loadView {
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectZero];
    self.view = view;
    self.screenView = view;
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    CGSize size = self.view.frame.size;
    
    
    NSLog(@"Virtual size: %dx%d", PIX_W, PIX_H);
    NSLog(@"Onscreen size: %fx%f", size.width, size.height);

    int hFactor = (int)size.height / PIX_H;
    int wFactor = (int)size.width /  PIX_W;
    NSLog(@"wFactor = %d, hFactor = %d", wFactor, hFactor);
    
    self.screenView.pixelMultiplier = MAX(hFactor, wFactor);

    NSLog(@"_pixelMultiplier = %d", _pixelMultiplier);
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
