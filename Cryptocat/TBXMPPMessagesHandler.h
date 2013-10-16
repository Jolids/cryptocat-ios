//
//  TBXMPPMessagesHandler.h
//  Cryptocat
//
//  Created by Thomas Balthazar on 01/10/13.
//  Copyright (c) 2013 Thomas Balthazar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TBDidReceiveGroupChatMessageNotification;

@class TBXMPPManager, TBOTRManager, XMPPMessage, XMPPJID;

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
@interface TBXMPPMessagesHandler : NSObject

- (id)initWithXMPPManager:(TBXMPPManager *)XMPPManager;
- (void)handleMessage:(XMPPMessage *)message myRoomJID:(XMPPJID *)myRoomJID;
- (void)sendGroupMessage:(NSString *)message;

@end