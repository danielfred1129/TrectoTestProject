//
//  ArticleTableViewCell.m
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import "ArticleTableViewCell.h"
#import "AFNetworking.h"

@implementation ArticleTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setImageURL:(NSURL*)imageURL
{
    [self.postImageView cancelImageRequestOperation];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:imageURL];
    [self.postImageView setImageWithURLRequest:urlRequest
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           self.postImageView.image = image;
                                           if(request != nil && response != nil)
                                           {
                                               self.postImageView.alpha = 0.0;
                                               [UIView animateWithDuration:0.5 animations:^{
                                                   self.postImageView.alpha = 1.0;
                                               }];
                                           }
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                               NSLog(@"OKO");
                                       }];   
}
@end
