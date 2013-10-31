//
//  OSKInMemoryImageCache.m
//  Overshare
//
//  Created by Jared Sinclair on 10/22/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKInMemoryImageCache.h"

@implementation OSKInMemoryImageCache

+ (id)sharedInstance {
    static dispatch_once_t once;
    static OSKInMemoryImageCache * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

@end
