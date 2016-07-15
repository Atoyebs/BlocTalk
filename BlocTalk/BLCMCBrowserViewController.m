//
//  BLCMCBrowserViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 12/07/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMCBrowserViewController.h"
#import "BLCConnectorCell.h"
#import "BLCUser.h"
#import "BLCDataSource.h"
#import "BLCAppDelegate.h"
#import "BLCMultiPeerManager.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface BLCMCBrowserViewController()

@property (nonatomic, strong) BLCDataSource *dataSource;
@property (nonatomic, strong) BLCAppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableDictionary *deviceConnectionStatusDictionary;
@property (nonatomic, strong) NSMutableArray *kvoConnectedDevicesMutableArray;

@end

static NSString *const connected = @"Connected";
static NSString *const notConnected = @"Not Connected";

@implementation BLCMCBrowserViewController


-(void)viewDidLoad {

    self.dataSource = [BLCDataSource sharedInstance];
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFindPeerWithNotification:) name:@"MCDidFindPeerNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLosePeerWithNotification:) name:@"MCDidLosePeer" object:nil];
    
    self.kvoConnectedDevicesMutableArray = [self.dataSource mutableArrayValueForKey:NSStringFromSelector(@selector(connectedDevices))];
    
    self.deviceConnectionStatusDictionary = [NSMutableDictionary new];
    
    [self.deviceConnectionStatusDictionary setValue:self.kvoConnectedDevicesMutableArray forKey:connected];
    [self.deviceConnectionStatusDictionary setValue:self.dataSource.unConnectedFoundDevices forKey:notConnected];
    
    self.title = @"Connections";
    
    [self.tableView registerClass:[BLCConnectorCell class] forCellReuseIdentifier:@"onlyFoundCell"];
    [self.tableView registerClass:[BLCConnectorCell class] forCellReuseIdentifier:@"connectedCell"];
    
    #warning There should be a switch UI element implementing this
    [self.appDelegate.mpManager advertisePeer:YES];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.dataSource.unConnectedFoundDevices = nil;
    self.dataSource.unConnectedFoundDevices = [NSMutableArray array];
    
    [self.deviceConnectionStatusDictionary setValue:self.dataSource.unConnectedFoundDevices forKey:notConnected];
    
}


-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


-(void)didFindPeerWithNotification:(NSNotification *)notification {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}


-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    
    MCSession *session = [[notification userInfo] objectForKey:@"session"];
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    NSIndexPath *indexPathForPeerID = nil;
    NSArray *allValuesForConnectionDictionary = [self.deviceConnectionStatusDictionary allValues];
    
    for (NSArray *array in allValuesForConnectionDictionary) {
        
        if ([array containsObject:peerID]) {
            
            NSInteger section = [allValuesForConnectionDictionary indexOfObject:array];
            NSInteger row = [array indexOfObject:peerID];
            indexPathForPeerID = [NSIndexPath indexPathForRow:row inSection:section];
            
        }
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{

        //if the session is NOT connecting
        if (state != MCSessionStateConnecting) {
            BLCConnectorCell *cellToUpdate = [self.tableView cellForRowAtIndexPath:indexPathForPeerID];
            [cellToUpdate stopAnimatingConnectionIndicator];
        }
        
        //reload data here
        [self.tableView reloadData];
    });
    
    if (state == MCSessionStateConnected) {
    
        NSBlockOperation *sendFoundInitialUserDataOperation = [NSBlockOperation blockOperationWithBlock:^{
           
            //send the user you've just connected to your information;
            NSData *myUserInfoToSend = [BLCUser currentDeviceUserInDataFormat];
            
            NSLog(@"Just about to send initial data for user");
            
            [session sendData:myUserInfoToSend toPeers:[NSArray arrayWithObject:peerID] withMode:MCSessionSendDataReliable error:nil];
            
        }];
        
        sendFoundInitialUserDataOperation.qualityOfService = NSQualityOfServiceUtility;
        sendFoundInitialUserDataOperation.queuePriority = NSOperationQueuePriorityNormal;
        
        [self.appDelegate.multiPeerOperationQueue addOperation:sendFoundInitialUserDataOperation];
    }
        
}


-(void)didLosePeerWithNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - UITableViewDelegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.deviceConnectionStatusDictionary.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *allValues = [self.deviceConnectionStatusDictionary allValues];
    NSArray *arrayForSection = [allValues objectAtIndex:section];
    
    return arrayForSection.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLCConnectorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"onlyFoundCell"];
    
    NSString *currentSectionTitle = [[self.deviceConnectionStatusDictionary allKeys] objectAtIndex:indexPath.section];
    
    if ([currentSectionTitle isEqualToString:connected]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"connectedCell"];
        cell.textLabel.textColor = [UIColor greenColor];
    }
    else {
        cell.textLabel.textColor = [UIColor orangeColor];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    NSArray *allValues = [self.deviceConnectionStatusDictionary objectForKey:currentSectionTitle];
    
    MCPeerID *currentPeerID = [allValues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentPeerID.displayName;
    
    return cell;
    
    
}

//-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    
//    
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *currentSectionTitle = [[self.deviceConnectionStatusDictionary allKeys] objectAtIndex:indexPath.section];
    
    NSArray *allValues = [self.deviceConnectionStatusDictionary objectForKey:currentSectionTitle];
    
    MCPeerID *currentPeerID = [allValues objectAtIndex:indexPath.row];
    
    BLCConnectorCell *cell = (BLCConnectorCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell startAnimatingConnectionIndicator];
    
    [self.appDelegate.mpManager invitePeer:currentPeerID withUserInfo:[BLCUser currentDeviceUser]];
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *allValues = [self.deviceConnectionStatusDictionary allKeys];
    NSString *headerForSection = [allValues objectAtIndex:section];
    
    return headerForSection;
}


#pragma mark - Actions

- (IBAction)refreshPeerBrowser:(id)sender {
    [self.appDelegate.mpManager refreshBrowsingForPeers]; 
}



@end
