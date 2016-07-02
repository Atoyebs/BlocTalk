//
//  BLCMessageListTableViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 20/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCConversationListViewController.h"
#import "BLCMessageTableViewCell.h"
#import <PureLayout/PureLayout.h>
#import "BLCConversationViewController.h"

@interface BLCConversationListViewController ()

@property (nonatomic, strong) NSArray *testData;
@property (nonatomic, strong) UINib *messageCellViewNib;
@property (nonatomic, strong) UIColor *backgroundColorBlue;
@property (nonatomic, strong) UILabel *noConversationsInfoLabel;
@property (nonatomic, strong) UIView *noConversationsMainView;

@end

@implementation BLCConversationListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    self.testData = @[@"Ini Atoyebi", @"Tireni Atoyebi"];
    
    self.testData = [NSArray new];
    
    self.backgroundColorBlue = [UIColor colorWithRed:0.81 green:0.89 blue:0.95 alpha:1.0];
    
    self.tableView.backgroundColor = self.backgroundColorBlue;
    
    [self setUpNoConversationsViewCheckingDataArray:self.testData];
    
}



- (void)setUpNoConversationsViewCheckingDataArray:(NSArray *)conversationsArray {
    
    if (conversationsArray.count == 0 || !conversationsArray) {
        
        CGSize deviceSize = [UIScreen mainScreen].bounds.size;
        
        self.noConversationsInfoLabel = [UILabel new];
        self.noConversationsInfoLabel.numberOfLines = 3;
        self.noConversationsInfoLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18.0f];
        self.noConversationsInfoLabel.text = @"There's Nothing Here. Tap + To Start A New Chat";
        [self.tableView addSubview:self.noConversationsInfoLabel];
        
        [self.noConversationsInfoLabel autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
        [self.noConversationsInfoLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.tableView withOffset:deviceSize.height/3.5];
        
        NSMutableAttributedString *attributedLabelText = [[NSMutableAttributedString alloc] initWithAttributedString:self.noConversationsInfoLabel.attributedText];
        
        [attributedLabelText addAttribute:NSForegroundColorAttributeName value:self.tableView.tintColor range:NSMakeRange(26, 1)];
        self.noConversationsInfoLabel.attributedText = attributedLabelText;
        
        [self.noConversationsInfoLabel autoSetDimension:ALDimensionWidth toSize:(self.tableView.frame.size.width * 0.50)];
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.testData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


//- (IBAction)startNewConversation:(id)sender {
//    
//    BLCConversationMessagesViewController *vc = [[BLCConversationMessagesViewController alloc] init];
//    vc.senderId = @"Ini";
//    vc.senderDisplayName = @"Ini.Atoyebi";
//    
//    [self.navigationController pushViewController:vc animated:YES];
//    
//}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
    }
    
    // Configure the cell...
    
    NSString *currentName = [self.testData objectAtIndex:indexPath.section];
    cell.textLabel.text = currentName;
    cell.imageView.image = [UIImage imageNamed:@"Landscape-Placeholder.png"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = self.backgroundColorBlue;
    
    return cell;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.backgroundColorBlue;
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = self.backgroundColorBlue;
    return view;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
