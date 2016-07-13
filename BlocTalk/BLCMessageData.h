//
//  BLCMessageData.h
//  BlocTalk
//
//  Created by Inioluwa Work Account on 13/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessage.h>

@interface BLCMessageData : JSQMessage

@property (nonatomic, strong) UIImage *image;

-(instancetype)initWithSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date text:(NSString *)text image:(UIImage *)image;

+(instancetype)messageWithSenderId:(NSString *)senderId displayName:(NSString *)displayName text:(NSString *)text image:(UIImage *)image;

@end
