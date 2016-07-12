//
//  BLCAvailableContactsSelecterTableViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 01/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCAvailableContactsSelecterTableViewController.h"
#import "BLCDataSource.h"
#import "BLCUser.h"
#import "BLCConversation.h"
#import "BLCAppDelegate.h"
#import "BLCConversationViewController.h"
#import <MultiPeerConnectivity/MultipeerConnectivity.h>

@interface BLCAvailableContactsSelecterTableViewController ()

@property (nonatomic, strong) BLCDataSource *mainDataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *finishedSelectingRecipientsButton;
@property (nonatomic, strong) NSMutableArray *kvoConnectedDevicesArray;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@end

@implementation BLCAvailableContactsSelecterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.mainDataSource = [BLCDataSource sharedInstance];
    
    self.kvoConnectedDevicesArray = [self.mainDataSource mutableArrayValueForKey:NSStringFromSelector(@selector(connectedDevices))];
    
#warning comment the below out for testing
//    if (self.mainDataSource.connectedDevices.count < 1) {
//        [[self.mainDataSource getConnectedDevices] addObject:@"Number 1"];
//        [[self.mainDataSource getConnectedDevices] addObject:@"Number 2"];
//        [[self.mainDataSource getConnectedDevices] addObject:@"Number 3"];
//        [[self.mainDataSource getConnectedDevices] addObject:@"Number 4"];
//        [[self.mainDataSource getConnectedDevices] addObject:@"Number 5"];
//    }
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.kvoConnectedDevicesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    MCPeerID *currentPeerID = [self.kvoConnectedDevicesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentPeerID.displayName;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger selectedRowCount = self.tableView.indexPathsForSelectedRows.count;
    
    if (selectedRowCount > 0) {
        self.finishedSelectingRecipientsButton.enabled = YES;
    }
    
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger selectedRowCount = self.tableView.indexPathsForSelectedRows.count;
    
    if (selectedRowCount == 0) {
        self.finishedSelectingRecipientsButton.enabled = NO;
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSArray <MCPeerID *> *selectedPeers = [self selectedRecipientsArray];
    
    BOOL conversationExists = [self.mainDataSource doesConversationAlreadyExistForRecipients:selectedPeers];
    
    if (conversationExists) {
        
        NSLog(@"Conversation Already Exists!");
        
        if ([segue.identifier isEqualToString:@"pushToConversationVC"]) {
            
            BLCConversationViewController *conversationViewController = (BLCConversationViewController *)[segue destinationViewController];
            
            BLCConversation *conv = [self.mainDataSource findExistingConversationWithRecipients:selectedPeers];
            
            if (conv) {
                
                conversationViewController.conversation = conv;
                conversationViewController.senderId = conv.user.initializingUserID;
                conversationViewController.senderDisplayName = conv.user.username;
                
            }
            
        }

        
    }
    else if ([segue.identifier isEqualToString:@"pushToConversationVC"]) {
        
        NSLog(@"We are starting a brand new conversation");
        
        [self pushNewConversation:segue sender:sender recipients:selectedPeers];
    }
    
    
}


-(NSArray *)selectedRecipientsArray {
    
    NSMutableArray *selectedPeers = [NSMutableArray new];
    
    NSArray *selectedIndexesArray = [self.tableView indexPathsForSelectedRows];
    
    for (id obj in selectedIndexesArray) {
        
        NSIndexPath *indexPath = (NSIndexPath *)obj;
        
        NSNumber *indexPathRow = [NSNumber numberWithInteger:indexPath.row];
        
        id retrievedObj = [self.kvoConnectedDevicesArray objectAtIndex:indexPathRow.integerValue];
        
        if ([retrievedObj isKindOfClass:[NSString class]]) {
            NSString *stringObj = (NSString *)retrievedObj;
            [selectedPeers addObject:stringObj];
        }
        else  {
            MCPeerID *peerID = (MCPeerID *)retrievedObj;
            [selectedPeers addObject:peerID];
        }
        
        
    }

    return selectedPeers;
    
}


-(void)pushNewConversation:(UIStoryboardSegue *)segue sender:(id)sender recipients:(NSArray *)selectedPeers {
    
    BLCConversationViewController *convoVC = (BLCConversationViewController *)[segue destinationViewController];
    
    if (selectedPeers.count > 0) {
        
        BLCConversation *newConversation = [[BLCConversation alloc] init];
        newConversation.recipients = selectedPeers;
        
        BLCUser *initialisingUser = [[BLCUser alloc] init];
        initialisingUser.username = self.appDelegate.userName;
        initialisingUser.initializingUserID = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        
        newConversation.user = initialisingUser;
        
        convoVC.senderId = newConversation.user.initializingUserID;
        convoVC.senderDisplayName = newConversation.user.username;
        
        if (selectedPeers.count == 1) {
            newConversation.isGroupConversation = NO;
        }
        
        convoVC.conversation = newConversation;
        
    }
}

@end
