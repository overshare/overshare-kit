//
//  OSKTumblrActivity.h
//  Overshare
//
//
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKActivity.h"

#import "OSKBloggingActivity.h"
#import "OSKActivity_ManagedAccounts.h"
#import "OSKActivity_GenericAuthentication.h"

@interface OSKTumblrActivity : OSKActivity <OSKBloggingActivity, OSKActivity_ManagedAccounts>

@end
