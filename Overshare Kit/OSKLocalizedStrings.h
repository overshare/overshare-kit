//
//  OSKLocalizedStrings.h
//  Overshare
//
//  Created by Flavio Caetano on 1/8/14.
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef OSKLocalizedString
#define OSKLocalizedString(key, comment) \
NSLocalizedStringFromTableInBundle((key), nil, [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"OSKLocalizations" ofType:@"bundle"]], nil)
#endif