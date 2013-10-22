//
//  TBBuddiesViewController.h
//  Cryptocat
//
//  Created by Thomas Balthazar on 17/10/13.
//  Copyright (c) 2013 Thomas Balthazar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TBBuddiesViewControllerDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TBBuddiesViewController : UITableViewController

@property (nonatomic, weak) id <TBBuddiesViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSMutableArray *usernames;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@protocol TBBuddiesViewControllerDelegate <NSObject>

- (void)buddiesViewControllerHasFinished:(TBBuddiesViewController *)controller;
- (void)buddiesViewController:(TBBuddiesViewController *)controller
        didSelectConversation:(NSString *)conversation;

@end