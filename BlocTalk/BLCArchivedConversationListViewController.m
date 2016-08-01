//
//  BLCArchivedConversationListViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 27/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCArchivedConversationListViewController.h"
#import "BLCArchivedConversationCell.h"
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

@property (nonatomic, assign) BOOL isInEditMode;


@property (nonatomic, strong) UIBarButtonItem *editBarButton, *doneBarButton, *cancelBarButton;

@property (nonatomic, strong) NSMutableIndexSet *conversationsToUnarchive;

@end


@implementation BLCArchivedConversationListViewController


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.backGColor = [UIColor colorWithRed:0.95 green:0.76 blue:0.22 alpha:1.0];
    
    self.tableView.backgroundColor = self.backGColor;
    
    [self.tableView registerClass:[BLCArchivedConversationCell class] forCellReuseIdentifier:@"cell"];

    self.kvoArchivedConversationsArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(archivedConversations))];
    
    [self.dataSource addObserver:self forKeyPath:NSStringFromSelector(@selector(archivedConversations)) options:0 context:nil];
    
    self.editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editButtonPressed:)];
    
    self.isInEditMode = NO;
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Unarchive" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
    
    self.cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed:)];
    
    
    self.navigationItem.rightBarButtonItem = self.editBarButton;
    
}


-(void)dealloc {
    [self.dataSource removeObserver:self forKeyPath:NSStringFromSelector(@selector(archivedConversations))];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)editButtonPressed:(UIBarButtonItem *)sender {
    
    [self.navigationItem setRightBarButtonItem:self.cancelBarButton animated:YES];
    
    self.isInEditMode = YES;
    
    if (!self.conversationsToUnarchive) {
        self.conversationsToUnarchive = [NSMutableIndexSet indexSet];
    }
    
    for (BLCArchivedConversationCell *cell in self.tableView.visibleCells) {
        [cell showCustomEditAccessoryView];
    }
    
    
}


-(void)doneButtonPressed:(UIBarButtonItem *)sender {
    
    self.isInEditMode = NO;
    
    [self.navigationItem setRightBarButtonItem:self.editBarButton animated:YES];
    
    if ([self.tableView indexPathsForSelectedRows].count > 0) {
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            [self.conversationsToUnarchive addIndex:indexPath.section];
        }
        
    }
    
    [self.dataSource unarchiveConversations:self.conversationsToUnarchive];
    
    for (BLCArchivedConversationCell *cell in self.tableView.visibleCells) {
        [cell hideAllCellEditAccessoryControls];
    }
    
}


-(void)cancelButtonPressed:(UIBarButtonItem *)sender {
    
    self.isInEditMode = NO;
    
    self.conversationsToUnarchive = nil;
    
    for (BLCArchivedConversationCell *cell in self.tableView.visibleCells) {
        [cell hideAllCellEditAccessoryControls];
    }
    
    [self.navigationItem setRightBarButtonItem:self.editBarButton animated:YES];
    
}


-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    self.isInEditMode = NO;
    [self.navigationItem setRightBarButtonItem:self.editBarButton animated:YES];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.kvoArchivedConversationsArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCArchivedConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[BLCArchivedConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
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
    
    BLCArchivedConversationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.messagePreviewTextView becomeFirstResponder];
    
    if (self.isInEditMode) {
        
        [cell changeEditAccessoryViewControl];
        
        [self.conversationsToUnarchive addIndex:indexPath.section];
        
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];
        
    }
    else {
        cell.selected = NO;
        [self performSegueWithIdentifier:@"pushExistingConversation" sender:self];
    }
    
    
    
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCArchivedConversationCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.messagePreviewTextView becomeFirstResponder];
    
    if (self.isInEditMode) {
        
        [cell changeEditAccessoryViewControl];
        
        [self.conversationsToUnarchive removeIndex:indexPath.section];
        
        if (self.conversationsToUnarchive.count <  1 && [self.navigationItem.rightBarButtonItem isEqual:self.doneBarButton]) {
            [self.navigationItem setRightBarButtonItem:self.cancelBarButton animated:YES];
        }
        
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(archivedConversations))]) {
        
        NSLog(@"\n\nChange Occuring In Archived Conversations Array");
        
        // We know the property has changed.  Let's see what kind of change it is.
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // A new property for archivedConversations has been set
            [self.tableView reloadData];
        }
        else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
            
            // Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Call `beginUpdates` to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            // Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadSections:indexSetOfChanges withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the table view that we're done telling it about changes, and to complete the animation
            [self.tableView endUpdates];
            
        }
        
        
        [self.tableView reloadData];
    }
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCArchivedConversationCell *cellToDisplay = (BLCArchivedConversationCell *)cell;
    
    [cellToDisplay hideAllCellEditAccessoryControls];
    
    NSLog(@"Cell Selected State = %@", (cell.selected)? @"Selected" : @"Not Selected");
    
    if (self.isInEditMode) {
        [cellToDisplay changeEditAccessoryViewControl];
    }
    
    [cellToDisplay updateConversationCell];
    
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
