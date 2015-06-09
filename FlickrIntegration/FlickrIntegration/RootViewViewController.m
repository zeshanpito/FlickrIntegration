//
//  RootViewViewController.m
//  FlickrIntegration
//
//  Created by Zeshan Hayder on 09/06/2015.
//  Copyright (c) 2015 Putitout. All rights reserved.
//

#import "RootViewViewController.h"
#import "LoginViewController.h"
#import "FlickrKit.h"

@interface RootViewViewController ()
    @property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, strong) FKDUNetworkOperation *uploadOperation;
- (IBAction)uploadImagePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progressbar;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@end

@implementation RootViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender {
    LoginViewController *loginView = [LoginViewController new];
    [self.navigationController pushViewController:loginView animated:YES];
}




- (void) userAuthenticateCallback:(NSNotification *)notification {
    NSURL *callbackURL = notification.object;
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackURL completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                //[self userLoggedIn:userName userID:userId];
                NSLog(@"%@",userName);
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }];
}
- (IBAction)uploadImagePressed:(id)sender {
    NSDictionary *uploadArgs = @{@"title": @"Test Photo", @"description": @"A Test Photo via FlickrKitDemo", @"is_public": @"0", @"is_friend": @"0", @"is_family": @"0", @"hidden": @"2"};
    self.progressbar.progress = 0.0;
    self.uploadOperation = [[FlickrKit sharedFlickrKit] uploadImage:[UIImage imageNamed:@"ToUpload"] args:uploadArgs completion:^(NSString *imageID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            } else {
                NSString *msg = [NSString stringWithFormat:@"Uploaded image ID %@", imageID];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            [self.uploadOperation removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
        });
    }];
    
    [self.uploadOperation addObserver:self forKeyPath:@"uploadProgress" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
        self.progressbar.progress = progress;
        //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    });
}
@end
