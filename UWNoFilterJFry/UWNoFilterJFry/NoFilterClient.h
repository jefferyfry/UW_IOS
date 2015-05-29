//
//  NoFilterClient.h
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 2/20/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@protocol NoFilterClientDelegate <NSObject>
@optional
-(void)loginUserResult:(BOOL)success;
-(void)registerUserResult:(BOOL)success;
-(void)uploadPhotoResult:(BOOL)success withId:(NSNumber*)serverId;
-(void)serverListResult:(NSArray*)itemIds;
-(void)downloadPhotoResult:(NSURL*)location withId:(NSNumber*)serverId;
@end

@interface NoFilterClient : NSObject
@property (weak) id<NoFilterClientDelegate> delegate;
+(id)sharedClient;
-(void)registerNewUser:(NSString *)username withPassword:(NSString *)password;
-(void)loginUser:(NSString *)username withPassword:(NSString *)password;
-(void)uploadPhoto:(Photo *)photo;
-(void)getServerList;
-(void)downloadPhoto:(NSNumber*)serverId;
@end
