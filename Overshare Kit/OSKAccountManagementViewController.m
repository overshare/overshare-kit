//
//  OSKAccountManagementViewController.m
//  Overshare
//
//  Created by Jared Sinclair on 10/29/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKAccountManagementViewController.h"

#import "OSKPresentationManager.h"
#import "OSKActivity.h"
#import "OSKAppDotNetActivity.h"
#import "OSKInstapaperActivity.h"
#import "OSKPocketActivity.h"
#import "OSKReadabilityActivity.h"
#import "OSKPinboardActivity.h"
#import "OSKAccountChooserViewController.h"
#import "UIColor+OSKUtility.h"
#import "OSKPocketAccountViewController.h"
#import "OSKAccountTypeCell.h"

@interface OSKAccountManagementViewController ()

@property (strong, nonatomic) NSArray *activityClasses;

@end

@implementation OSKAccountManagementViewController

- (instancetype)initWithIgnoredActivityClasses:(NSArray *)ignoredActivityClasses optionalBespokeActivityClasses:(NSArray *)arrayOfClasses {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.title = [[OSKPresentationManager sharedInstance] localizedText_Accounts];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonPressed:)];

        NSMutableArray *classes = [[NSMutableArray alloc] init];

        NSMutableSet *defaultClasses = [NSMutableSet set];
        [defaultClasses addObject:[OSKAppDotNetActivity class]];
        [defaultClasses addObject:[OSKInstapaperActivity class]];
        [defaultClasses addObject:[OSKPocketActivity class]];
        [defaultClasses addObject:[OSKReadabilityActivity class]];
        [defaultClasses addObject:[OSKPinboardActivity class]];
        
        for (Class ignoredClass in ignoredActivityClasses) {
            if ([defaultClasses containsObject:ignoredClass]) {
                [defaultClasses removeObject:ignoredClass];
            }
        }
        
        [classes addObjectsFromArray:defaultClasses.allObjects];
        
        if (arrayOfClasses.count) {
            for (Class activityClass in arrayOfClasses) {
                NSAssert([activityClass isSubclassOfClass:[OSKActivity class]], @"OSKAccountChooserViewController requires an OSKActivity subclass passed to initForManagingAccountsOfActivityClass:");
                BOOL usesAppropriateAuthentication = NO;
                if ([activityClass authenticationMethod] == OSKAuthenticationMethod_ManagedAccounts
                    || [activityClass authenticationMethod] == OSKAuthenticationMethod_Generic) {
                    usesAppropriateAuthentication = YES;
                }
                NSAssert(usesAppropriateAuthentication, @"OSKAccountChooserViewController requires a subclass of OSKActivity that conforms to OSKActivity_ManagedAccounts");
            }
            [classes addObjectsFromArray:arrayOfClasses];
        }
        
        [classes sortUsingComparator:^NSComparisonResult(Class class1, Class class2) {
            return [(NSString *)[class1 activityName] compare:(NSString *)[class2 activityName] options:NSCaseInsensitiveSearch];
        }];
        
        [self setActivityClasses:classes];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
    UIColor *bgColor = [presentationManager color_groupedTableViewBackground];
    self.view.backgroundColor = bgColor;
    self.tableView.backgroundColor = bgColor;
    self.tableView.backgroundView.backgroundColor = bgColor;
    self.tableView.separatorColor = presentationManager.color_separators;
    [self.tableView registerClass:[OSKAccountTypeCell class] forCellReuseIdentifier:OSKAccountTypeCellIdentifier];
}

- (void)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activityClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSKAccountTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:OSKAccountTypeCellIdentifier forIndexPath:indexPath];
    Class activityClass = self.activityClasses[indexPath.row];
    [cell setActivityClass:activityClass];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class activityClass = self.activityClasses[indexPath.row];
    if ([activityClass authenticationMethod] == OSKAuthenticationMethod_ManagedAccounts) {
        OSKAccountChooserViewController *chooser = [[OSKAccountChooserViewController alloc] initForManagingAccountsOfActivityClass:activityClass];
        [self.navigationController pushViewController:chooser animated:YES];
    } else {
        OSKPocketAccountViewController *pocketVC = [[OSKPocketAccountViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:pocketVC animated:YES];
    }
}

@end




