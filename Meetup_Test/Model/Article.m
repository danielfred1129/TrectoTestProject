//
//  Article.m
//  Meetup_Test
//
//  Created by Daniel on 12/11/14.
//  Copyright (c) 2014 Daniel. All rights reserved.
//

#import "Article.h"

@implementation Article

- (id) init
{
    if (self)
    {
        self.articleContent = nil;
        self.articleId = nil;
        self.articleImageURL = nil;
    }
    return self;
}

@end
