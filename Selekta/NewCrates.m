//
//  NewCrates.m
//  Selekta
//
//  Created by Charisse Ann Dirain on 5/22/17.
//  Copyright © 2017 Charisse Ann Dirain. All rights reserved.
//

#import "NewCrates.h"
#import "SetsCell.h"
#import "NVSlideMenuController.h"
#import "SearchViewController.h"

#import "NewCrateObj.h"
#import "Config.h"
#import "CrateCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "AccountsClient.h"
#import "UIImageView+WebCache.h"
#import "PlayerVC.h"
#import "AppDelegate.h"
#import "CrateRealm1.h"
#import <QuartzCore/QuartzCore.h>
#import "PlayerNewVC.h"
#import "SetObj.h"
#import "SetsRealm.h"
#import "TableViewController.h"

@interface NewCrates (){
    
    
    NSUserDefaults *defaults;
    NSString *playerID;
    
    IBOutlet UIImageView *tutorial1;
    IBOutlet UIButton *next1;
}
@property (nonatomic, retain) NSMutableArray *crates;
@property (nonatomic) BOOL isShown;
@end

@implementation NewCrates

@synthesize crates,isShown;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=YES;
    self.searchField.delegate=self;
    self.searchField.hidden=YES;
    self.goBtn.hidden=NO;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error: nil];
    [[AVAudioSession sharedInstance] setActive: YES error:nil];
    
    // Prevent the application from going to sleep while it is running
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    // Starts receiving remote control events and is the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    crates=[[NSMutableArray alloc] init];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    playerID = [defaults objectForKey:@"GLOBAL_USER_ID"];
    
    
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"tutorial"]  isEqual: @"0"]){
        tutorial1.hidden = NO;
        
        next1.hidden = NO;
        
    }else{
        tutorial1.hidden = YES;
        
        next1.hidden = YES;
        
    }
    
    [[AccountsClient sharedInstance] getSingleAccountInfoWithID:playerID completion:^(NSError *error, FDataSnapshot *accountInfo)  {
        
        NSLog(@"accountInfo = %@", accountInfo);
        NSLog(@"accountInfo = %@", accountInfo.value[@"profilePic_url"]);
        
        //self.crateTitle.text = [NSString stringWithFormat:@"%@'s CRATE", accountInfo.value[@"name"]];
        self.crateTitle.text = @"CRATE";
        if( [[defaults objectForKey:@"GLOBAL_IS_FB"] boolValue] ){
            //[cell.avatar setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:person[@"picture"]]]]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:accountInfo.value[@"profilePic_url"]]];
                
                //set your image on main thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"profile pic url %@",accountInfo.value[@"profilePic_url"]);
                    [self.profImg setImage:[UIImage imageWithData:data]];
                    self.profImg.layer.cornerRadius = 36;
                    self.profImg.clipsToBounds = YES;
                });
            });
        }
    }];
    
    
    [self observers];
    //[self fetchData];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidUnload{
    [self removeObserverGetSets];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    self.navigationController.navigationBar.hidden=YES;
    [self observers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma table delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"crate %@",crates);
    if([crates count] == 0){
        return 1;
    }else{
        return [crates count]+1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 84;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return YES - we will be able to delete all rows
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    NSLog(@"Deleted row.");
    if(crates.count>0){
        [crates removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.setLbl.text=[NSString stringWithFormat:@"%lu TRACKS IN YOUR CRATE",(unsigned long)[crates count]];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"setsCell";
    
    SetsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SetsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if([crates count]==0){
        cell.artist.text= @"Your Crate";
        cell.title1.text=@"";//[NSString stringWithFormat:@"From: %@", obj.settitle];
        cell.backgroundView = [[UIView alloc] init];
        //cell.backgroundView.backgroundColor = [UIColor blackColor];
        [cell.img setImage:[UIImage imageNamed:@"crate_default_button.png"]];
        //[cell.img sd_setImageWithURL:[NSURL URLWithString:@""]
                    //placeholderImage:[UIImage imageNamed:@"crate_default_button.png"]];
        
        return cell;
    }else{
        if(indexPath.row == 0){
            cell.artist.text= @"Your Crate";
            cell.title1.text=@"";//[NSString stringWithFormat:@"From: %@", obj.settitle];
            cell.backgroundView = [[UIView alloc] init];
            //cell.backgroundView.backgroundColor = [UIColor blackColor];
            //[cell.img sd_setImageWithURL:[NSURL URLWithString:@""]
                        //placeholderImage:[UIImage imageNamed:@"blackbtn.png"]];
            
            [cell.img setImage:[UIImage imageNamed:@"crate_default_button.png"]];

            
            return cell;
        }else{
            
            NSLog(@"indexpath %ld",(long)indexPath.row);
            SetObj *ob=(SetObj *)[crates objectAtIndex:(indexPath.row-1)];
            cell.artist.text= ob.set_artist;
            NSLog(@"set title %@",ob.set_title);
            cell.title1.text=@"";//ob.set_title;
            //cell.img.file=ob.imgfile;
            //[cell.img loadInBackground];
            [cell.img sd_setImageWithURL:[NSURL URLWithString:ob.set_btn_image]
                        placeholderImage:[UIImage imageNamed:@"blackbtn.png"]];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            
            NSInteger colorIndex = indexPath.row % 3;
            switch (colorIndex) {
                case 0:
                    
                    cell.backgroundView.backgroundColor = [UIColor colorWithRed:(226/255.0) green:(220/255.0) blue:(198/255.0) alpha:1];
                    break;
                case 1:
                    cell.backgroundView.backgroundColor = [UIColor colorWithRed:(206/255.0) green:(206/255.0) blue:(206/255.0) alpha:1];
                    break;
                case 2:
                    cell.backgroundView.backgroundColor = [UIColor colorWithRed:(163/255.0) green:(160/255.0) blue:(166/255.0) alpha:1];
                    break;
            }
            
            
            return cell;
        }
    }
    
    
    
    return cell;
    
}

#pragma mark - Show menu

- (IBAction)showMenu:(id)sender
{
    [self.searchField resignFirstResponder];
    
    if(self.slideMenuController.isMenuOpen==YES){
        [self.slideMenuController closeMenuAnimated:YES completion:nil];
    }else{
        [self.slideMenuController openMenuAnimated:YES completion:nil];
    }
    
    [_searchField resignFirstResponder];
    
}

/*-(IBAction)onSearch:(id)sender{
 
 if(isShown==FALSE){
 self.searchField.hidden=NO;
 self.goBtn.hidden=YES;
 self.searchBtn.hidden=NO;
 [self.searchField becomeFirstResponder];
 isShown=TRUE;
 }else{
 self.searchField.hidden=YES;
 self.goBtn.hidden=YES;
 self.searchBtn.hidden=NO;
 [self.searchField resignFirstResponder];
 isShown=FALSE;
 }
 
 }*/

-(IBAction)goSearch:(id)sender{
    
    SearchViewController *detailsVC = [SearchViewController new];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
    [self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.slideMenuController.isMenuOpen==NO){
        
        
        /*CrateObj *crate=[self.crates objectAtIndex:indexPath.row];
        NSLog(@"set id %@",crate.set_id);
        NSString *recentset=[[NSUserDefaults standardUserDefaults] objectForKey:@"recentset"];
        NSString *recentid=[[NSUserDefaults standardUserDefaults] objectForKey:@"recentid"];
        NSString *cid= [NSString stringWithFormat:@"%ld",([crate.trackID integerValue])];
        NSLog(@"cid %@",cid);
        if([recentset isEqualToString:crate.set_id]){
            //check the recent trac
            
            [[NSUserDefaults standardUserDefaults] setObject:crate.set_id forKey:@"selectedset"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"selected set %@",crate.set_id);
            
            
            [[NSUserDefaults standardUserDefaults] setObject:cid forKey:@"recentid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            
            
            [[NSUserDefaults standardUserDefaults] setObject:crate.set_id forKey:@"selectedset"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:cid forKey:@"recentid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"nowplaying"];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"fromcrate"];
        [[NSUserDefaults standardUserDefaults] setObject:crate.trackID forKey:@"trackstart"];
        [[NSUserDefaults standardUserDefaults] setObject:crate.set_id forKey:@"trackset"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PlayerNewVC *signVC = (PlayerNewVC *)[storyboard instantiateViewControllerWithIdentifier:@"PlayerVC"];
        [[AppDelegate sharedInstance].audioPlayer stop];
        
        [self.slideMenuController closeMenuBehindContentViewController:signVC animated:YES completion:nil];*/
        
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"nowplaying"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        TableViewController *detailsVC = [TableViewController new];
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
        [self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
    }
}

-(IBAction)onGo:(id)sender{
    
    SearchViewController *detailsVC = [SearchViewController new];
    detailsVC.searchString=self.searchField.text;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
    [self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    [textField resignFirstResponder];
    
    self.searchField.hidden=YES;
    self.goBtn.hidden=YES;
    self.searchBtn.hidden=NO;
    
    SearchViewController *detailsVC = [SearchViewController new];
    detailsVC.searchString=self.searchField.text;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:detailsVC];
    [self.slideMenuController closeMenuBehindContentViewController:navController animated:YES completion:nil];
    
    return NO;
}

-(void)observers{
    
    [[AccountsClient sharedInstance] getAllSets:@"ALL" completion:^(NSError *error, FDataSnapshot *sets1) {
        
        NSLog(@"All Sets = %@", sets1.value);
        
        NSString *playerid=[defaults objectForKey:@"GLOBAL_USER_ID"];
        
        if (sets1.value != (id)[NSNull null]) {
            
            [self.crates removeAllObjects];
            
            
            
            RLMRealm *realm = [RLMRealm defaultRealm];
            
            for (int i=0; i < [sets1.value count]; i++) {
                
                NSDictionary *setid = [sets1.value objectAtIndex:i];
                if(setid != (id)[NSNull null]){
                    NSLog(@"setid = %@", setid[@"set_artist"]);
                    SetObj *setobj = [[SetObj alloc] init];
                    NSString *sobjID = [NSString stringWithFormat:@"%d",i];
                    setobj.objectId = sobjID;
                    
                    setobj.set_artist=setid[@"set_artist"];
                    setobj.set_audio_link=setid[@"setf_audio_link"];
                    setobj.set_id=setid[@"setid"];
                    setobj.set_title=setid[@"set_title"];
                    setobj.created_at=setid[@"dateCreated"];
                    setobj.updated_at=setid[@"dateCreated"];
                    setobj.set_picture=setid[@"set_picture"];
                    setobj.set_background_pic=setid[@"set_background_pic"];
                    setobj.set_btn_image=setid[@"set_btn_image"];
                    //[self.sets addObject:setobj];
                    
                    
                    SetsRealm *tobjr = [[SetsRealm alloc] init];
                    tobjr.objectId = sobjID;
                    
                    tobjr.set_artist=setid[@"set_artist"];
                    tobjr.set_audio_link=setid[@"setf_audio_link"];
                    tobjr.set_id=setid[@"setid"];
                    tobjr.set_title=setid[@"set_title"];
                    tobjr.created_at=setid[@"dateCreated"];
                    tobjr.updated_at=setid[@"dateCreated"];
                    tobjr.set_picture=setid[@"set_picture"];
                    tobjr.set_background_pic=setid[@"set_background_pic"];
                    tobjr.set_btn_image=setid[@"set_btn_image"];
                    tobjr.userid = playerid;
                    
                    // Updating book with id = 1
                    [realm beginWriteTransaction];
                    [realm addOrUpdateObject:tobjr];
                    [realm commitWriteTransaction];
                    
                    
                    
                }
                
                
            }
            
            NSPredicate *billingPredicate = [NSPredicate predicateWithFormat: @"userid = %@", playerid];
            RLMResults<SetsRealm *> *res = [[SetsRealm objectsWithPredicate: billingPredicate]
                                            sortedResultsUsingProperty:@"created_at" ascending:NO];
            NSLog(@"crates %@",res);
            [crates removeAllObjects];
            
            if(res.count>0){
                
                for (int i=0;i<res.count;i++){
                    SetsRealm *r = (SetsRealm *)[res objectAtIndex:i];
                    SetObj *tobjr = [[SetObj alloc] init];
                    tobjr.objectId = r.objectId;
                    
                    tobjr.set_artist=r.set_artist;
                    tobjr.set_audio_link=r.set_audio_link;
                    tobjr.set_id=r.set_id;
                    tobjr.set_title=r.set_title;
                    tobjr.created_at=r.created_at;
                    tobjr.updated_at=r.updated_at;
                    tobjr.set_picture=r.set_picture;
                    tobjr.set_background_pic=r.set_background_pic;
                    tobjr.set_btn_image=r.set_btn_image;
                    [crates addObject:tobjr];
                    
                }
                
                [self.thisTableView reloadData];
            }
            
           // self.setLbl.text=[NSString stringWithFormat:@"%lu SELEKTA SETS",(unsigned long)[sets count]];
            
        }
        
    }];
    
}

-(void) removeObserverGetSets{
    
    Firebase *ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/sets", FIREBASE_URL]];
    
    [ref removeAllObservers];
}


-(IBAction)goTutorialNext:(id)sender{
    
    tutorial1.hidden = YES;
    
    
    next1.hidden = YES;
    
    
}

@end
