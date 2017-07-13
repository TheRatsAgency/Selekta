//
//  NewCrates.h
//  Selekta
//
//  Created by Charisse Ann Dirain on 5/22/17.
//  Copyright © 2017 Charisse Ann Dirain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCrates : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *thisTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *goBtn,*searchBtn;
@property (weak, nonatomic) IBOutlet UILabel *setLbl,*crateTitle;
@property(nonatomic, retain) IBOutlet UIImageView *profImg;

@end

