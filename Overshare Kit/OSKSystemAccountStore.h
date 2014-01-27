//
//  OSKSystemAccountManager.h
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Foundation;
@import Accounts;

#import "OSKActivity_SystemAccounts.h"

///-----------------------------------------------
/// @name System Account Store
///-----------------------------------------------

/**
 `OSKSystemAccountStore` is used as a singleton instance. It conveniently 
 manages access to iOS' Accounts API
 */
@interface OSKSystemAccountStore : NSObject

/**
 @return Returns the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 Checks if access has been granted to system accounts of a given account type identifier.
 
 @param accountTypeIdentifier The iOS account type identifier (See ACAccountType.h)
 
 @return Returns `YES` if access has been granted.
 */
- (BOOL)accessGrantedForAccountsWithAccountTypeIdentifier:(NSString *)accountTypeIdentifier;

/**
 Requests access to the system accounts, if any have been setup by the user.
 
 @param accountTypeIdentifier The iOS account type identifier (See ACAccountType.h)
 
 @param completion A completion handler called at the end of the request, whether it succeeds or fails.
 */
- (void)requestAccessToAccountsWithAccountTypeIdentifier:(NSString *)accountTypeIdentifier
                                              completion:(OSKSystemAccountAccessRequestCompletionHandler)completion;


/**
 Returns an array of the ACAccounts already obtained.
 
 @param accountTypeIdentifier The iOS account type identifier (See ACAccountType.h)
 
 @return An array of ACAccounts, or nil.
 */
- (NSArray *)accountsForAccountTypeIdentifier:(NSString *)accountTypeIdentifier;

/**
 Renews the credentials for the account.
 
 @param account The account whose credentials are being renewed.
 
 @param completion A completion handler called at the end of the renewal request.
 
 @discussion Facebook credentials are revoked after surprisingly short periods of time, even for iOS 
 manged accounts.
 */
- (void)renewCredentialsForAccount:(ACAccount *)account
                        completion:(void(^)(ACAccountCredentialRenewResult renewResult, NSError *error))completion;

@end





