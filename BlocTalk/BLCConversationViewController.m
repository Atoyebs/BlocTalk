//
//  BLCConversationMessagesViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationViewController.h"
#import "BLCPersistanceObject.h"
#import "BLCNavBarConversationTitleView.h"
#import "BLCMultiPeerManager.h"
#import "BLCConversation.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCUser.h"
#import "BLCAppDelegate.h"
#import "BLCDataSource.h"
#import "BLCTextMessage.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BLCMultiPeerConnector.h"
#import <JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesCollectionViewFlowLayoutInvalidationContext.h>
#import <JSQMessagesBubbleImage.h>
#import <JSQMessagesAvatarImage.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <AFDropdownNotification/AFDropdownNotification.h>
#import "UIColor+JSQMessages.h"



@interface BLCConversationViewController () <BLCMultiPeerTextMessageDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *currentlyAvailablePeers;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray <BLCConversation *> *kvoConversationsArray;
@property (nonatomic, strong) BLCNavBarConversationTitleView *titleView;
@property (nonatomic, strong) UITapGestureRecognizer *collectionViewGestureRecognizer;

@end


@implementation BLCConversationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (!self.selectedFromArchiveVC) {
        
        self.titleView = [[BLCNavBarConversationTitleView alloc] init];
        self.navigationItem.titleView = self.titleView;
        
        if (self.conversation.recipients.count > 1) {
            self.titleView.conversationUserNameLabel.text = @"Multiple Recipients";
        }
        else if (self.conversation.recipients.count == 1) {
            MCPeerID *peer = [self.conversation.recipients firstObject];
            self.titleView.conversationUserNameLabel.text = peer.displayName;
        }
        else {
            self.titleView.conversationUserNameLabel.text = @"Unknown";
        }
        
    }
    else {
        
        if (self.conversation.recipients.count > 1) {
            self.title = @"Multiple Recipients";
        }
        else if (self.conversation.recipients.count == 1) {
            MCPeerID *peer = [self.conversation.recipients firstObject];
            self.title = peer.displayName;
        }
        else {
            self.title = @"Unknown";
        }
        
    }
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    self.kvoConversationsArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(conversations))];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateNotification:) name:@"MCDidChangeStateNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPeerIsTypingNotification) name:@"MCPeerIsTypingNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPeerStoppedTypingNotification) name:@"MCPeerStoppedTypingNotification" object:nil];
    
    self.collectionViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTapped)];
    self.collectionViewGestureRecognizer.numberOfTapsRequired = 1;
    self.collectionViewGestureRecognizer.numberOfTouchesRequired = 1;
    
    self.collectionViewGestureRecognizer.delegate = self;
    [self.collectionView addGestureRecognizer:self.collectionViewGestureRecognizer];
    
    self.inputToolbar.contentView.textView.editable = YES;
    
    if (self.selectedFromArchiveVC) {
        self.inputToolbar.contentView.textView.editable = NO;
        self.inputToolbar.contentView.textView.placeHolder = @"Disabled";
    }
    
    
}


-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.inputToolbar.contentView.textView becomeFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];
    
    self.appDelegate.mpManager.txtMssgDelegate = self;
    
    if (!self.conversation.isGroupConversation && ![self.dataSource isPeerConnected:self.conversation.recipients.firstObject]) {
        [self.titleView animateConnectionStatusLabelToShowDisconnected];
    }
    else {
        [self.titleView animateConnectionStatusLabelToShowConnected];
    }
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)peerDidChangeStateNotification:(NSNotification *)notification {
    
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state == MCSessionStateConnected) {
        
        if (!self.conversation.isGroupConversation && [self.conversation.recipients containsObject:peerID]) {
            [self.titleView animateConnectionStatusLabelToShowConnected];
        }
        
    }
    else if(state == MCSessionStateNotConnected) {
        
        //if it is an individual conversation and the recipient is the same as the peerID just sent then ...
        if (!self.conversation.isGroupConversation && [self.conversation.recipients containsObject:peerID]) {
            [self.titleView animateConnectionStatusLabelToShowDisconnected];
            
        }
        
    }
    
    
}

-(void)receivedPeerIsTypingNotification {
    [self setShowTypingIndicator:YES];
    [self scrollToBottomAnimated:YES];
}

-(void)receivedPeerStoppedTypingNotification {
    [self setShowTypingIndicator:NO];
}


-(void)collectionViewTapped {
    NSError *error;
    [self.appDelegate.mpManager.session startStreamWithName:@"stopped_typing" toPeer:self.conversation.recipients.firstObject error:&error];
    [self.view endEditing:YES];
    [self.inputToolbar.contentView.textView resignFirstResponder];
}


#pragma mark - JSQMessagesCollectionViewDataSource


-(id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.conversation.messages objectAtIndex:indexPath.item];
}


-(void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
}


-(void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.conversation.messages removeObjectAtIndex:indexPath.item];
    [self.collectionView reloadData];
    
}


-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCJSQMessageWrapper *message = [self.conversation.messages objectAtIndex:indexPath.item];
    UIImage *imageToUse = nil;
    
    //if the person who sent the message was me
    if ([message.senderId isEqualToString:self.senderId]) {
        #warning consider putting this method into a UIImage category
        imageToUse = self.appDelegate.userProfileImage;
    }
    else {
        imageToUse = message.image;
    }
    
    
    
   
    JSQMessagesAvatarImage *currentAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:imageToUse diameter:23];
    
//    JSQMessagesAvatarImage*currentAvatar = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:[self getInitialsFromDisplayName:message.senderDisplayName]backgroundColor:selectedColor textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:10.0f] diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    return currentAvatar;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    BLCJSQMessageWrapper *message = [self.conversation.messages objectAtIndex:indexPath.item];
    
    JSQMessagesBubbleImage *bubbleImageToUse = self.conversation.incomingBubbleImageData;
    
    if ([message.senderId isEqualToString:self.senderId]) {
        bubbleImageToUse = self.conversation.outgoingBubbleImageData;
    }
    
   
    return bubbleImageToUse;
}



-(void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    
    BLCJSQMessageWrapper *message = [[BLCJSQMessageWrapper alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text image:nil];
    
    NSBlockOperation *sendTextMessageOperation = [NSBlockOperation blockOperationWithBlock:^{
       
        NSError *sendTextMessageError;
        
        if (self.conversation.messages.count == 0) {
            sendTextMessageError = [self sendTextMessageToRecipients:text asInitialMessage:YES];
        }
        else {
            sendTextMessageError = [self sendTextMessageToRecipients:text asInitialMessage:NO];
        }
        
        if (!sendTextMessageError) {
            
           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
               [self.conversation.messages addObject:message];
               
               if (!self.conversation.isArchived) {
                   
                   [BLCPersistanceObject persistObjectToMemory:self.dataSource.conversations forFileName:NSStringFromSelector(@selector(conversations)) withCompletionBlock:^(BOOL persistSuccesful) {
                       
                       if (!persistSuccesful) {
                           NSLog(@"persisting the message to the conversation list was unsuccesful!");
                       }
                       
                   }];
                   
               }
               
               [self.dataSource unarchiveConversation:self.conversation];
               
               if (self.conversation.messages.count == 1) {
                   [self.kvoConversationsArray insertObject:self.conversation atIndex:0];
               }
               
               if (self.conversation.recipients.count == 1) {
                   
                   NSDictionary *dictionary = @{@"recipient" : [self.conversation.recipients firstObject], @"conversation" : self.conversation };
                   
                   [[NSNotificationCenter defaultCenter] postNotificationName:PostToIndividualConversation object:nil userInfo:dictionary];
               }
               else {
                   
                   NSDictionary *recipientsDictionary = @{@"recipients" : self.conversation.recipients};
                   
                   [[NSNotificationCenter defaultCenter] postNotificationName:PostToGroupConversation object:nil userInfo:recipientsDictionary];
               }
               
               [self finishSendingMessage];
               
           }];
            
        }
        else {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
               
                UIAlertController *messageSendingErrorController = [UIAlertController alertControllerWithTitle:@"Message Send Error" message:sendTextMessageError.localizedFailureReason preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                
                [messageSendingErrorController addAction:okAction];
                
                [self presentViewController:messageSendingErrorController animated:YES completion:nil];
                
            }];
            
        }

        
    }];
    sendTextMessageOperation.queuePriority = NSOperationQueuePriorityNormal;
    [self.appDelegate.multiPeerOperationQueue addOperation:sendTextMessageOperation];
    
}

-(NSError *)sendTextMessageToRecipients:(NSString *)textMessage asInitialMessage:(BOOL)initialMessage {
    
    NSMutableArray *recipientsToSend = [self.conversation.recipients mutableCopy];
    [recipientsToSend addObject:self.appDelegate.mpManager.session.myPeerID];
    
    BLCTextMessage *message = [[BLCTextMessage alloc] initWithTextMessage:textMessage withUser:[BLCUser currentDeviceUserNoProfilePic] peersInConversation:recipientsToSend];
    message.isInitialMessageForChat = initialMessage;
    
    NSData *dataToSend = [NSKeyedArchiver archivedDataWithRootObject:message];
    
    NSError *error;
    
    [self.appDelegate.mpManager.session sendData:dataToSend
                                                    toPeers:self.conversation.recipients
                                                   withMode:MCSessionSendDataReliable
                                                      error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
 
    return error;
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
    
    BLCJSQMessageWrapper *msg = [self.conversation.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


-(NSString *)getInitialsFromDisplayName:(NSString *)displayName {
    
    NSMutableString *initials = [NSMutableString new];
    
    NSInteger firstTwoUpperCaseCharactersCount = 0;
    
    for (int i = 0; i < [displayName length]; i++) {
        
        if([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[displayName characterAtIndex:i]]){
            
            if (firstTwoUpperCaseCharactersCount > 2) {
                break;
            }
            else {
                NSString *charToAppend = [NSString stringWithFormat:@"%C", [displayName characterAtIndex:i]];
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


-(void)didReceiveTextMessage:(BLCTextMessage *)message withPeerID:(MCPeerID *)peerID {
    
    [self finishReceivingMessage];
    self.showTypingIndicator = NO;
    [self.collectionView reloadData];
    
}


-(void)textViewDidChange:(UITextView *)textView {
    
    [super textViewDidChange:textView];
    
    NSError *error;
    
    if (textView.text.length >= 1) {
        [self.appDelegate.mpManager.session startStreamWithName:@"typing" toPeer:self.conversation.recipients.firstObject error:&error];
    }
    else {
        [self.appDelegate.mpManager.session startStreamWithName:@"stopped_typing" toPeer:self.conversation.recipients.firstObject error:&error];
    }
    
}


-(void)textViewDidEndEditing:(UITextView *)textView {
    
    [super textViewDidEndEditing:textView];
    
    NSError *error;
    
    [self.appDelegate.mpManager.session startStreamWithName:@"stopped_typing" toPeer:self.conversation.recipients.firstObject error:&error];
    
}


@end
