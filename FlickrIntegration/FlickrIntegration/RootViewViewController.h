//
//  RootViewViewController.h
//  FlickrIntegration
//
//  Created by Zeshan Hayder on 09/06/2015.
//  Copyright (c) 2015 Putitout. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ELCImagePicker/ELCImagePickerHeader.h"
@interface RootViewViewController : UIViewController <ELCImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonPressed:(id)sender;
@end
