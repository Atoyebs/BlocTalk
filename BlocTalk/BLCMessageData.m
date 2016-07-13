//
//  BLCMessageData.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 13/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMessageData.h"

@implementation BLCMessageData


-(instancetype)initWithSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date text:(NSString *)text image:(UIImage *)image {
    
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    
    if (self) {
        self.image = image;
    }
    
    return self;
}


+(instancetype)messageWithSenderId:(NSString *)senderId displayName:(NSString *)displayName text:(NSString *)text image:(UIImage *)image {
    
    BLCMessageData *message = [BLCMessageData messageWithSenderId:senderId displayName:displayName text:text];
    message.image = image;
    
    return message;
}



@end
