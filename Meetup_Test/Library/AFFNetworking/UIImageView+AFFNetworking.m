// UIImageView+AFFNetworking.m
//
// Copyright (c) 2011 Gowalla (http://gowalla.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import "UIImageView+AFFNetworking.h"

@interface AFFImageCache : NSCache
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end

#pragma mark -

static char kAFFImageRequestOperationObjectKey;

@interface UIImageView (_AFFNetworking)
@property (readwrite, nonatomic, strong, setter = AFF_setImageRequestOperation:) AFFImageRequestOperation *AFF_imageRequestOperation;
@end

@implementation UIImageView (_AFFNetworking)
@dynamic AFF_imageRequestOperation;
@end

#pragma mark -

@implementation UIImageView (AFFNetworking)

- (AFFHTTPRequestOperation *)AFF_imageRequestOperation {
    return (AFFHTTPRequestOperation *)objc_getAssociatedObject(self, &kAFFImageRequestOperationObjectKey);
}

- (void)AFF_setImageRequestOperation:(AFFImageRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, &kAFFImageRequestOperationObjectKey, imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)AFF_sharedImageRequestOperationQueue {
    static NSOperationQueue *_AFF_imageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AFF_imageRequestOperationQueue = [[NSOperationQueue alloc] init];
        [_AFF_imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });

    return _AFF_imageRequestOperationQueue;
}

+ (AFFImageCache *)AFF_sharedImageCache {
    static AFFImageCache *_AFF_imageCache = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _AFF_imageCache = [[AFFImageCache alloc] init];
    });

    return _AFF_imageCache;
}

#pragma mark -

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

    [self setImageWithURLRequest:request placeholderImage:placeholderImage success:nil failure:nil];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self cancelImageRequestOperation];

    UIImage *cachedImage = [[[self class] AFF_sharedImageCache] cachedImageForRequest:urlRequest];
    if (cachedImage) {
        if (success) {
            success(nil, nil, cachedImage);
        } else {
            self.image = cachedImage;
        }

        self.AFF_imageRequestOperation = nil;
    } else {
        self.image = placeholderImage;

        AFFImageRequestOperation *requestOperation = [[AFFImageRequestOperation alloc] initWithRequest:urlRequest];
        [requestOperation setCompletionBlockWithSuccess:^(AFFHTTPRequestOperation *operation, id responseObject) {
            if ([urlRequest isEqual:[self.AFF_imageRequestOperation request]]) {
                if (success) {
                    success(operation.request, operation.response, responseObject);
                } else if (responseObject) {
                    self.image = responseObject;
                }

                if (self.AFF_imageRequestOperation == operation) {
                    self.AFF_imageRequestOperation = nil;
                }
            }

            [[[self class] AFF_sharedImageCache] cacheImage:responseObject forRequest:urlRequest];
        } failure:^(AFFHTTPRequestOperation *operation, NSError *error) {
            if ([urlRequest isEqual:[self.AFF_imageRequestOperation request]]) {
                if (failure) {
                    failure(operation.request, operation.response, error);
                }

                if (self.AFF_imageRequestOperation == operation) {
                    self.AFF_imageRequestOperation = nil;
                }
            }
        }];

        self.AFF_imageRequestOperation = requestOperation;

        [[[self class] AFF_sharedImageRequestOperationQueue] addOperation:self.AFF_imageRequestOperation];
    }
}

- (void)cancelImageRequestOperation {
    [self.AFF_imageRequestOperation cancel];
    self.AFF_imageRequestOperation = nil;
}

@end

#pragma mark -

static inline NSString * AFFImageCacheKeyFromURLRequest(NSURLRequest *request) {
    return [[request URL] absoluteString];
}

@implementation AFFImageCache

- (UIImage *)cachedImageForRequest:(NSURLRequest *)request {
    switch ([request cachePolicy]) {
        case NSURLRequestReloadIgnoringCacheData:
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData:
            return nil;
        default:
            break;
    }

	return [self objectForKey:AFFImageCacheKeyFromURLRequest(request)];
}

- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request
{
    if (image && request) {
        [self setObject:image forKey:AFFImageCacheKeyFromURLRequest(request)];
    }
}

@end

#endif
