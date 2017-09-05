//
//  SettingsVC.m
//  Selekta
//
//  Created by Charisse Ann Dirain on 5/16/16.
//  Copyright © 2016 Matias Muhonen. All rights reserved.
//

#import "SettingsVC.h"
#import "NVSlideMenuController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "AppDelegate.h"

@interface SettingsVC (){
    
    IBOutlet UIButton *next1;
}
@property (nonatomic, retain) IBOutlet UISwitch *myswitch;
@property (nonatomic, retain) IBOutlet UISwitch *myswitch1;
@property (strong, nonatomic) IBOutlet UIStepper *stepper;


@end

@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error:nil];
    
    // Prevent the application from going to sleep while it is running
    //[UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Starts receiving remote control events and is the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    self.navigationController.navigationBar.hidden = YES;
    
    NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch"];
    if([value isEqualToString:@"on"]){
        _myswitch.on = true;
    }else{
        _myswitch.on = false;
    }
    
    NSString *value1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"switch1"];
    if([value1 isEqualToString:@"on"]){
        _myswitch1.on = true;
    }else{
        _myswitch1.on = false;
    }
    
    self.stepper.wraps=YES;
    self.stepper.autorepeat=YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showMenu:(id)sender
{
    
    if(self.slideMenuController.isMenuOpen==YES){
        [self.slideMenuController closeMenuAnimated:YES completion:nil];
        
    }else{
        [self.slideMenuController openMenuAnimated:YES completion:nil];
    }
    
}

-(IBAction)changeSwitch:(id)sender{
    
    if([sender isOn]){
        NSLog(@"Switch is ON");
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"switch"];
    } else{
        NSLog(@"Switch is OFF");
        [[NSUserDefaults standardUserDefaults] setObject:@"off" forKey:@"switch"];
    }
    
}

-(IBAction)changeSwitch1:(id)sender{
    
    if([sender isOn]){
        NSLog(@"Switch is ON");
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:@"switch1"];
        [[AppDelegate sharedInstance].audioPlayer resume];
        [AppDelegate sharedInstance].audioPlayer.volume = [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] doubleValue];
    } else{
        NSLog(@"Switch is OFF");
        [[NSUserDefaults standardUserDefaults] setObject:@"off" forKey:@"switch1"];
        [[AppDelegate sharedInstance].audioPlayer pause];
        [AppDelegate sharedInstance].audioPlayer.volume = 0.0;
    }
    
}

- (IBAction)valueDidChanged:(UIStepper *)sender {
    //Whenever the stepper value increase and decrease the sender.value fetch the curent value of stepper
    double value= sender.value;
    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:@"volume"];
    [AppDelegate sharedInstance].audioPlayer.volume = sender.value;
    
    
}

@end
