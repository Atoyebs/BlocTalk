//
//  BLCArchivedConversationListViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCArchivedConversationListViewController.h"
#import "BLCBaseConversationCell.h"
#import "BLCConversationListViewController.h"
#import "BLCPersistanceObject.h"
#import "BLCJSQMessageWrapper.h"
#import "BLCConversationViewController.h"
#import "BLCMultiPeerManager.h"
#import "BLCConversationCell.h"
#import "BLCNewConversationCell.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCTextMessage.h"
#import "BLCDataSource.h"
#import "BLCAppDelegate.h"
#import "HDNotificationView.h"
#import "MCSession+PeerDataManipulation.h"
#import "UITableViewCell+Swipe.h"
#import <PureLayout/PureLayout.h>
#import "BLCConversationViewController.h"
#import <JSQMessage.h>
#import <AFDropdownNotification/AFDropdownNotification.h>
#import <QuartzCore/QuartzCore.h>

@interface BLCArchivedConversationListViewController()

@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray <BLCConversation *> *kvoArchivedConversationsArray;
@property (nonatomic, strong) UIImageView *messageIconImageView;
@property (nonatomic, strong) UIColor *backGColor;
@end


@implementation BLCArchivedConversationListViewController


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.backGColor = [UIColor colorWithRed:0.95 green:0.76 blue:0.22 alpha:1.0];
    
    self.tableView.backgroundColor = self.backGColor;
    
    [self.tableView registerClass:[BLCBaseConversationCell class] forCellReuseIdentifier:@"cell"];

    self.kvoArchivedConversationsArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(archivedConversations))];
    
    [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(archivedConversations)) options:0 context:nil];
    
    
}


-(void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(archivedConversations))];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.kvoArchivedConversationsArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCBaseConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    // Configure the cell...
    BLCConversation *currConversation = [self.kvoArchivedConversationsArray objectAtIndex:indexPath.section];
    cell.conversation = currConversation;
    
    [cell setupCell];
    
    cell.tag = currConversation.conversationID;
    
    cell.backgroundColor = self.backGColor;
    
    return cell;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.backGColor;
    return view;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.backGColor;
    return view;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 90;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCBaseConversationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.messagePreviewTextView becomeFirstResponder];
    
    [self performSegueWithIdentifier:@"pushExistingConversation" sender:self];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"pushExistingConversation"]) {
        
        BLCConversationViewController *conversationViewController = (BLCConversationViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
        
        BLCConversation *conversation = [self.kvoArchivedConversationsArray objectAtIndex:selectedCellIndexPath.section];
        
        conversationViewController.selectedFromArchiveVC = YES;
        conversationViewController.conversation = conversation;
        conversationViewController.senderDisplayName = conversation.user.username;
        conversationViewController.senderId = conversation.user.initializingUserID;
        
    }
    
}


@end
