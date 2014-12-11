//
//  Article.h
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Article : NSObject

@property (nonatomic, strong) NSString *articleId;
@property (nonatomic, strong) NSString *articleImageURL;
@property (nonatomic, strong) NSString *articleContent;

@end
