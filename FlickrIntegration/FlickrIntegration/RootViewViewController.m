//
//  RootViewViewController.m
//  FlickrIntegration
//
//  Created by Zeshan Hayder on 09/06/2015.
//  Copyright (c) 2015 Putitout. All rights reserved.


#import "RootViewViewController.h"
#import "LoginViewController.h"
#import "FlickrKit.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "PictureTableViewCell.h"

@interface RootViewViewController ()

@property (nonatomic, strong) NSMutableArray *images;
    @property (nonatomic, retain) FKDUNetworkOperation *completeAuthOp;
@property (nonatomic, strong) FKDUNetworkOperation *uploadOperation;
- (IBAction)uploadImagePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIProgressView *progressbar;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
- (IBAction)multiSelectPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *mediaTableView;
@property (nonatomic, strong) NSDictionary *uploadArguments;
@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
//@property (
@end

@implementation RootViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAuthenticateCallback:) name:@"UserAuthCallbackNotification" object:nil];
    self.uploadArguments = @{@"title": @"Test Photo", @"description": @"A Test Photo via FlickrKitDemo", @"is_public": @"0", @"is_friend": @"0", @"is_family": @"0", @"hidden": @"2"};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

 In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     Get the new view controller using [segue destinationViewController].
     Pass the selected object to the new view controller.
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
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    });
}
- (IBAction)multiSelectPressed:(id)sender {
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.maximumImagesCount = 5;
    imagePicker.returnsOriginalImage = YES;
    imagePicker.returnsImage = YES;
    imagePicker.onOrder = YES;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.imagePickerDelegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    self.images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
            UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
            [self.images addObject:image];
        } else {
            NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
        }
    }
    
    
    
//    for (UIView *v in [_scrollView subviews]) {
//        [v removeFromSuperview];
//    }
//    
//    CGRect workingFrame = _scrollView.frame;
//    workingFrame.origin.x = 0;
//    
//    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
//    for (NSDictionary *dict in info) {
//        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
//            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
//                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                [images addObject:image];
//                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
//                imageview.frame = workingFrame;
//                
//                [_scrollView addSubview:imageview];
//                
//                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
//            } else {
//                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
//            }
//        } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
//            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
//                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
//                
//                [images addObject:image];
//                
//                UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
//                [imageview setContentMode:UIViewContentModeScaleAspectFit];
//                imageview.frame = workingFrame;
//                
//                [_scrollView addSubview:imageview];
//                
//                workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
//            } else {
//                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
//            }
//        } else {
//            NSLog(@"Uknown asset type");
//        }
//    }
//    
//    self.chosenImages = images;
//    
//    [_scrollView setPagingEnabled:YES];
//    [_scrollView setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];
    [self.mediaTableView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.mediaTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 109;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.images count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"PictureCell";
    
    PictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        //cell = [[PictureTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PictureTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    cell.selectedImageView.image = [self.images objectAtIndex:indexPath.row];
    
    
    [[FlickrKit sharedFlickrKit] uploadImage:[self.images objectAtIndex:indexPath.row] args:self.uploadArguments completion:^(NSString *imageID, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            } else {
                cell.statusLabel.text = @"Uploaded";
//                NSString *msg = [NSString stringWithFormat:@"Uploaded image ID %@", imageID];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Done" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                [alert show];
            }
            //[self.uploadOperation removeObserver:self forKeyPath:@"uploadProgress" context:NULL];
        });
    }];
    
    
    return cell;
}


@end
