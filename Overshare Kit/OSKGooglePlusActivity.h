//
//  OSKFacebookActivity.h
//  Overshare
//
//  Created by Peter Friese on 2/5/14.
//  Copyright (c) 2014 Google. All rights reserved.
//

#import "OSKActivity.h"

#import "OSKMicrobloggingActivity.h"
#import "OSKActivity_GenericAuthentication.h"

@interface OSKGooglePlusActivity : OSKActivity <OSKMicrobloggingActivity, OSKActivity_GenericAuthentication>

// Defaults to ACFacebookAudienceEveryone. See ACAccountType.h for all options.
@property (copy, nonatomic) NSString *currentAudience; // TODO(peterfriese): use circles!

@end
