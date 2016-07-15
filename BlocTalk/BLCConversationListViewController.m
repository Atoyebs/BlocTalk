//
//  BLCMessageListTableViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationListViewController.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCConversationViewController.h"
#import "BLCMultiPeerManager.h"
#import "BLCConversationCell.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCTextMessage.h"
#import "BLCDataSource.h"
#import "BLCAppDelegate.h"
#import "MCSession+PeerDataManipulation.h"
#import <PureLayout/PureLayout.h>
#import "BLCConversationViewController.h"
#import <JSQMessage.h>


@interface BLCConversationListViewController ()

@property (nonatomic, strong) UINib *messageCellViewNib;
@property (nonatomic, strong) UILabel *noConversationsInfoLabel;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray <BLCConversation *> *kvoConversationsArray;

@end

@implementation BLCConversationListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.tableView.backgroundColor = self.appDelegate.appThemeColor;
    
    [self setUpNoConversationsViewCheckingDataArray:self.dataSource.conversations];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendNewMessageToIndividual:) name:PostToIndividualConversation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendNewMessageToGroup:) name:PostToGroupConversation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDataWithNotificaion:) name:@"MCDidReceiveDataNotification" object:nil];
    
    [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(conversations)) options:0 context:nil];
    
    [self.tableView registerClass:[BLCConversationCell class] forCellReuseIdentifier:@"cell"];
    
    self.kvoConversationsArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(conversations))];
    
}




-(void)didReceiveDataWithNotificaion:(NSNotification *)notification {
    
    //This is a notification so isn't done on the main thread
        
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    
    MCSession *session = [[notification userInfo] objectForKey:@"session"];
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    
    BLCTextMessage *receivedText = (BLCTextMessage *)[NSKeyedUnarchiver unarchiveObjectWithData:receivedData];
    
    BLCConversation *conversation = nil;
    
    #warning find existing conversation with recipients might have to have different recipients than for this session
    conversation = [self.dataSource findExistingConversationWithRecipients:[session connectedPeers]];
    
    BLCUser *userWhoSentMessage = [self.dataSource.knownUsersDictionary objectForKey:receivedText.user.initializingUserID];
    
    if (conversation) {
        
        NSLog(@"Found the conversation! Yay!");
        
        BLCJSQMessageWrapper *receivedMessage = [BLCJSQMessageWrapper messageWithSenderId:receivedText.user.initializingUserID displayName:receivedText.user.username text:receivedText.textMessage image:self.appDelegate.profilePicturePlaceholderImage];
        
        if (userWhoSentMessage) {
            receivedMessage = [BLCJSQMessageWrapper messageWithSenderId:userWhoSentMessage.initializingUserID displayName:userWhoSentMessage.username text:receivedText.textMessage image:userWhoSentMessage.profilePicture];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [conversation.messages addObject:receivedMessage];
            
            [self sendMessageReceivedNotification:receivedMessage];
        });
        
    }
    else {
        
        NSLog(@"This is a new conversation");
        
        BLCConversation *brandNewConversation = [[BLCConversation alloc] init];
        
        BLCJSQMessageWrapper *receivedMessage = [BLCJSQMessageWrapper messageWithSenderId:receivedText.user.initializingUserID displayName:receivedText.user.username text:receivedText.textMessage image:self.appDelegate.profilePicturePlaceholderImage];
        
        if (userWhoSentMessage) {
            receivedMessage = [BLCJSQMessageWrapper messageWithSenderId:userWhoSentMessage.initializingUserID displayName:userWhoSentMessage.username text:receivedText.textMessage image:userWhoSentMessage.profilePicture];
        }
        
        
        #warning find existing conversation with recipients might have to have different recipients than for this session
        brandNewConversation.recipients = [session connectedPeers];
        
        brandNewConversation.isGroupConversation = ([session connectedPeers].count > 1) ? YES : NO;
        
        brandNewConversation.user = [BLCUser currentDeviceUser];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [brandNewConversation.messages addObject:receivedMessage];
            [self.kvoConversationsArray insertObject:brandNewConversation atIndex:0];
            
            [self sendMessageReceivedNotification:receivedMessage];
            
            if (!self.noConversationsInfoLabel.hidden) {
                self.noConversationsInfoLabel.hidden = YES;
                self.tableView.scrollEnabled = YES;
            }
            
        });
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (BLCConversationCell *cell in [self.tableView visibleCells]) {
            [cell updateConversationCell];
        }
        [self.tableView reloadData];
    });
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.appDelegate.mpManager startBrowsingForPeers];
    
}

-(void)didSendNewMessageToIndividual:(NSNotification *)notification {
    
    MCPeerID *recipientPeerID = [[notification userInfo] objectForKey:@"recipient"];
    
    BLCConversation *conversation = [[notification userInfo] objectForKey:@"conversation"];
    
    BLCUser *user = [self.dataSource findUserObjectWithPeerID:recipientPeerID];
    
    if (!self.noConversationsInfoLabel.isHidden) {
        self.noConversationsInfoLabel.hidden = YES;
        self.tableView.scrollEnabled = YES;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        NSIndexPath *indexPath = [self.dataSource getIndexPathForConversation:conversation];
        
        BLCConversationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [cell updateConversationCellWithProfilePictureFromUser:user];
        
    });

    
    
}


-(void)didSendNewMessageToGroup:(NSNotification *)notification {
    
    NSArray <MCPeerID *> *recipients = [[notification userInfo] objectForKey:@"recipients"];
    
}


- (void)setUpNoConversationsViewCheckingDataArray:(NSArray *)conversationsArray {
    
    if (conversationsArray.count == 0 || !conversationsArray) {
        
        CGSize deviceSize = [UIScreen mainScreen].bounds.size;
        
        self.noConversationsInfoLabel = [UILabel new];
        self.noConversationsInfoLabel.numberOfLines = 3;
        self.noConversationsInfoLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20.0f];
        self.noConversationsInfoLabel.text = @"There's Nothing Here. Tap + To Start A New Chat";
        [self.tableView addSubview:self.noConversationsInfoLabel];
        
        [self.noConversationsInfoLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
        [self.noConversationsInfoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.tableView withOffset:deviceSize.height/3];
        
        NSMutableAttributedString *attributedLabelText = [[NSMutableAttributedString alloc] initWithAttributedString:self.noConversationsInfoLabel.attributedText];
        
        [attributedLabelText addAttribute:NSForegroundColorAttributeName value:self.tableView.tintColor range:NSMakeRange(26, 1)];
        self.noConversationsInfoLabel.attributedText = attributedLabelText;
        
        [self.noConversationsInfoLabel autoSetDimension:ALDimensionWidth toSize:(self.tableView.frame.size.width * 0.60)];
        
        self.tableView.scrollEnabled = NO;
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.kvoConversationsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(conversations))];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    // Configure the cell...
    BLCConversation *currConversation = [self.kvoConversationsArray objectAtIndex:indexPath.section];
    cell.conversation = currConversation;
    
    [cell setupCell];
    
    cell.tag = currConversation.conversationID;
    
    cell.backgroundColor = self.appDelegate.appThemeColor;
    
    return cell;
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCConversationCell *convCell = (BLCConversationCell *)cell;
    
    [convCell updateConversationCell];
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.appDelegate.appThemeColor;
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.appDelegate.appThemeColor;
    return view;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCConversationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.messagePreviewTextView becomeFirstResponder];
    
    [self performSegueWithIdentifier:@"pushExistingConversation" sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Key Value Compliance Logic

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (object == self.dataSource && [keyPath isEqualToString:NSStringFromSelector(@selector(conversations))]) {
        
        // We know conversations changed.  Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // Someone set a brand new conversations array
            [self.tableView reloadData];
        }
        else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
            
            // We have an incremental change: inserted, deleted, or replaced conversations
              
               // Get a list of the index (or indices) that changed
               NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
               
               NSMutableArray *indexArrayOfChanges = [NSMutableArray array];
               
               [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                   
                   NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:idx];
                   [indexArrayOfChanges addObject:path];
               }];
            
            
               // Call `beginUpdates` to tell the table view we're about to make changes
               [self.tableView beginUpdates];
               
               // Tell the table view what the changes are
               if (kindOfChange == NSKeyValueChangeInsertion) {
                   
                   [self.tableView insertSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationLeft];
                   [self.tableView insertRowsAtIndexPaths:indexArrayOfChanges withRowAnimation:UITableViewRowAnimationLeft];
                   
                   
               } else if (kindOfChange == NSKeyValueChangeRemoval) {
                   [self.tableView deleteSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationAutomatic];
               } else if (kindOfChange == NSKeyValueChangeReplacement) {
                   [self.tableView reloadSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationAutomatic];
               }
               
               // Tell the table view that we're done telling it about changes, and to complete the animation
               [self.tableView endUpdates];
        }
        
    }
    
    [self.tableView reloadData];
    
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:@"pushExistingConversation"]) {
        
        
        BLCConversationViewController *conversationViewController = (BLCConversationViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
        
        BLCConversation *conversation = [self.kvoConversationsArray objectAtIndex:selectedCellIndexPath.section];
        
        conversationViewController.conversation = conversation;
        conversationViewController.senderDisplayName = conversation.user.username;
        conversationViewController.senderId = conversation.user.initializingUserID;
        
    }
    
    
}


#pragma mark - Custom Actions

-(void)sendMessageReceivedNotification:(BLCJSQMessageWrapper *)receivedMessage {

    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    NSDate *dateToFire = [NSDate dateWithTimeIntervalSinceNow:2.5];
    localNotification.fireDate = dateToFire;
    localNotification.alertBody = [NSString stringWithFormat:@"%@\n%@", receivedMessage.senderDisplayName, receivedMessage.text];
    localNotification.alertTitle = receivedMessage.senderDisplayName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

}


@end
