//
//  ArticleTableViewCell.h
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface ArticleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *postImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

-(void) setImageURL:(NSURL*)imageURL;

@end
