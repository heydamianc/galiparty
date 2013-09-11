//
//  GPYViewController.m
//  GaliParty
//
//  Created by Damian Carrillo on 9/11/13.
//  Copyright (c) 2013 Uncodin, Inc. All rights reserved.
//

#import "GPYViewController.h"

static const NSInteger      kFlashViewTag  = 1234;
static const NSTimeInterval kFlashDuration = 0.5;

@interface GPYViewController ()
@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (weak, nonatomic) IBOutlet UIImageView *discoBallView;
@property (assign, atomic, getter = isGalileoConnected) BOOL galileoConnected;
@end

@implementation GPYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self flashScreen];
 
    [self setFliteController:[[FliteController alloc] init]];
    [self setSlt:[[Slt alloc] init]];
    [self repeatedlySayParty];
    
    [[Galileo sharedGalileo] setDelegate:self];
    [[Galileo sharedGalileo] waitForConnection];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)waitForConnection
{
    [self setGalileoConnected:NO];
    [[self discoBallView] setHidden:YES];
    
    [[Galileo sharedGalileo] waitForConnection];
    [self flashScreen];
}

- (void)flashScreen
{
    UIView *destinationView = [[UIView alloc] initWithFrame:[[self view] bounds]];
    [destinationView setTag:kFlashViewTag];
    [destinationView setAlpha:0.f];
    
    if ([[[[[self view] subviews] lastObject] backgroundColor] isEqual:[UIColor redColor]]) {
        [destinationView setBackgroundColor:[UIColor whiteColor]];
    } else {
        [destinationView setBackgroundColor:[UIColor redColor]];
    }
    
    [[self view] addSubview:destinationView];
    
    [UIView animateWithDuration:kFlashDuration animations:^{
        [destinationView setAlpha:kFlashViewTag];
    } completion:^(BOOL finished) {
        for (UIView *subview in [[self view] subviews]) {
            if ([subview tag] == kFlashViewTag && subview != destinationView) {
                [subview removeFromSuperview];
            }
        }
        
        if (![self isGalileoConnected]) {
            [self flashScreen];
        } else {
            [self showDiscoBall];
        }
    }];
}

- (void)showDiscoBall
{
    [[self discoBallView] setHidden:NO];
    
    for (UIView *subview in [[self view] subviews]) {
        if ([subview tag] == kFlashViewTag) {
            [UIView animateWithDuration:kFlashDuration animations:^{
                [subview setAlpha:0.f];
            } completion:^(BOOL finished) {
                [subview removeFromSuperview];
            }];
        }
    }
}

- (void)repeatedlySayParty
{
    if ([self isGalileoConnected]) {
        [[self fliteController] say:@"Party" withVoice:[self slt]];
    }
    
    [self performSelector:@selector(repeatedlySayParty)
               withObject:nil
               afterDelay:kFlashDuration];
}

#pragma mark GalileoDelegate

- (void)galileoDidConnect
{
    [self setGalileoConnected:YES];
    
    VelocityControl* tiltVelocityControl = [[Galileo sharedGalileo] velocityControlForAxis:GalileoControlAxisTilt];
    [tiltVelocityControl setTargetVelocity:[tiltVelocityControl maxVelocity] / 10.0];
}

- (void)galileoDidDisconnect
{
    [self waitForConnection];
}

@end
