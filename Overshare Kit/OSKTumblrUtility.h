//
//  OSKTumblrUtility.h
//  Overshare
//
//  Created by Jared Sinclair on 10/10/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

@class OSKBlogPostContentItem;
@class OSKManagedAccountCredential;
@class OSKApplicationCredential;

@interface OSKTumblrUtility : NSObject

+ (void)postContentItem:(OSKBlogPostContentItem *)item
         withCredential:(OSKManagedAccountCredential *)credential
          appCredential:(OSKApplicationCredential *)appCredential
             completion:(void(^)(BOOL success, NSError *error))completion; // called on main queue

@end



