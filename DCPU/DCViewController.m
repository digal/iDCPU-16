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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screen = [[DCScreenViewController alloc] init];
    NSLog(@"view: %@", screen.view);
    [self.scrollView addSubview:screen.view];
    screen.view.frame = CGRectMake(0, 0, 320, 256);
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
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

@end
