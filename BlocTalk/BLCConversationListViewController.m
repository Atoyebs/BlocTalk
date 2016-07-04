//
//  BLCMessageListTableViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationListViewController.h"
#import "BLCConversationViewController.h"
#import "BLCConversationCell.h"
#import "BLCConversation.h"
#import "BLCUser.h"
#import "BLCDataSource.h"
#import "BLCAppDelegate.h"
#import <PureLayout/PureLayout.h>
#import "BLCConversationViewController.h"
#import <JSQMessage.h>

@interface BLCConversationListViewController ()

@property (nonatomic, strong) UINib *messageCellViewNib;
@property (nonatomic, strong) UILabel *noConversationsInfoLabel;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) BLCDataSource *dataSource;

@end

@implementation BLCConversationListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.tableView.backgroundColor = self.appDelegate.appThemeColor;
    
    [self setUpNoConversationsViewCheckingDataArray:[self userConversations]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveConversationUpdate:) name:BLCConversationUpdate object:nil];
    
    [self.tableView registerClass:[BLCConversationCell class] forCellReuseIdentifier:@"cell"];
    
}

-(NSMutableArray *)userConversations {
    
    self.dataSource = [BLCDataSource sharedInstance];
    
    return [self.dataSource getConversations];
}


-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
   NSArray *visibleCells = [self.tableView visibleCells];
    
    for (BLCConversationCell *cell in visibleCells) {
        [cell updateConversationCell];
    }
    
    
}

-(void)didRecieveConversationUpdate:(NSNotification *)notification {
    
//    NSDictionary *notificationInfo = @{@"text":text, @"senderDisplayName":self.senderDisplayName, @"senderId":self.senderId};
    
    BLCConversation *updatedConversation = notification.userInfo[@"conversation"];
    
    if (updatedConversation) {
        [self.dataSource addConversation:updatedConversation];
    }
    
    self.noConversationsInfoLabel.hidden = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.tableView reloadData];
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
    return [self userConversations].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    }
    
    // Configure the cell...
    
    BLCConversation *currConversation = [[self userConversations] objectAtIndex:indexPath.section];
    cell.conversation = currConversation;
    
    [cell setupCell];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:@"pushExistingConversation"]) {
        
        BLCConversationViewController *conversationViewController = (BLCConversationViewController *)[segue destinationViewController];
        
        NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForSelectedRow];
        
        BLCConversation *conversation = [[self userConversations] objectAtIndex:selectedCellIndexPath.section];
        
        conversationViewController.conversation = conversation;
        conversationViewController.senderDisplayName = conversation.user.username;
        conversationViewController.senderId = conversation.user.username;
        
    }
    
    
}


@end
