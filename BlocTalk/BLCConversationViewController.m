//
//  BLCConversationMessagesViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationViewController.h"
#import "BLCConversation.h"
#import "BLCAppDelegate.h"
#import <JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesCollectionViewFlowLayoutInvalidationContext.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesAvatarImage.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import "UIColor+JSQMessages.h"



@interface BLCConversationViewController ()

@property (nonatomic, strong) NSArray *currentlyAvailablePeers;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImage;

@end


@implementation BLCConversationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (self.conversation.recipients.count > 1) {
        self.title = @"Multiple Recipients";
    }
    else if (self.conversation.recipients.count == 1) {
        self.title = [self.conversation.recipients firstObject];
    }
    else {
        self.title = @"Unknown";
    }
    
    self.collectionView.backgroundColor = self.appDelegate.appThemeColor;
    
    self.avatarImage = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:[self getInitialsFromSenderDisplayName] backgroundColor:[UIColor jsq_messageBubblePurplePinkColor] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:10.0f] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    

    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - JSQMessagesCollectionViewDataSource


-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.conversation.messages objectAtIndex:indexPath.item];
}

-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Tapped A Message!");
}


-(void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.conversation.messages removeObjectAtIndex:indexPath.item];
    
}


-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.avatarImage;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.conversation.outgoingBubbleImageData;
    }
    
    return self.conversation.incomingBubbleImageData;
}


-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    
    [self.conversation.messages addObject:message];
    [self finishSendingMessage];
    
    
}




#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.conversation.messages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


-(NSString *)getInitialsFromSenderDisplayName {
    
    NSMutableString *initials = [NSMutableString new];
    
    NSInteger firstTwoUpperCaseCharactersCount = 0;
    
    for (int i = 0; i < [self.senderDisplayName length]; i++) {
        
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[self.senderDisplayName characterAtIndex:i]]){
            
            if (firstTwoUpperCaseCharactersCount > 2) {
                break;
            }
            else {
                NSString *charToAppend = [NSString stringWithFormat:@"%C", [self.senderDisplayName characterAtIndex:i]];
                initials = [[initials stringByAppendingString: charToAppend] mutableCopy];
            }
            
            firstTwoUpperCaseCharactersCount++;
        }
        
    }
    
    if ([initials isEqualToString:@""]) {
        initials = [NSMutableString stringWithFormat:@"N/A"];
    }
    
    return initials;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
