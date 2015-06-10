//
//  PictureTableViewCell.h
//  FlickrIntegration
//
//  Created by Zeshan Hayder on 10/06/2015.
//  Copyright (c) 2015 Putitout. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@end
