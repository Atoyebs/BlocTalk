//
//  BLCMessageData.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 13/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCJSQMessageWrapper.h"

@implementation BLCJSQMessageWrapper


- (instancetype)initWithSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date text:(NSString *)text image:(UIImage *)image {
    
    self = [super initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:text];
    
    if (self) {
        self.image = image;
    }
    
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
    }
    
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
}


+ (instancetype)messageWithSenderId:(NSString *)senderId displayName:(NSString *)displayName text:(NSString *)text image:(UIImage *)image {
    
    BLCJSQMessageWrapper *message = [BLCJSQMessageWrapper messageWithSenderId:senderId displayName:displayName text:text];
    message.image = image;
    
    return message;
}



@end
