//
//  BLCConnectionsViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 28/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BLCConnectionsViewController.h"
#import "BLCAppDelegate.h"
#import "BLCMultiPeerConnector.h"
#import "BLCDataSource.h"

@interface BLCConnectionsViewController () <MCBrowserViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) BLCAppDelegate *appDelegate;


@property (weak, nonatomic) IBOutlet UITableView *connectedDevicesTable;

@property (weak, nonatomic) IBOutlet UIButton *searchForDeviceButton;

@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;

@property (weak, nonatomic) IBOutlet UILabel *makeDiscoverableLabel;

@property (weak, nonatomic) IBOutlet UISwitch *makeDiscoverableSwitch;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *makeDiscoverableDistanceFromTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopDistanceToView;


@property (nonatomic, strong) BLCDataSource *mainDataSource;

@end

@implementation BLCConnectionsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (BLCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.multiPeerManager setupPeerAndSession];
    [self.appDelegate.multiPeerManager advertisePeer:self.makeDiscoverableSwitch.isOn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
    
    self.mainDataSource = [BLCDataSource sharedInstance];
    
    self.connectedDevicesTable.delegate = self;
    self.connectedDevicesTable.dataSource = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions


- (IBAction)browseWithDevices:(id)sender {
    
    [self.appDelegate.multiPeerManager setupMCBrowser];
    self.appDelegate.multiPeerManager.browser.delegate = self;
    [self presentViewController:self.appDelegate.multiPeerManager.browser animated:YES completion:nil];
}


- (IBAction)toggleDiscoverableSwitch:(id)sender {
    
    [self.appDelegate.multiPeerManager advertisePeer:self.makeDiscoverableSwitch.isOn];
}


- (IBAction)disconnectButtonPressed:(id)sender {
    
    [self.appDelegate.multiPeerManager.peerSession disconnect];
    
    [[self.mainDataSource getConnectedDevices] removeAllObjects];
    [self.connectedDevicesTable reloadData];
}



-(void)updateViewConstraints {
    
    CGSize mainViewSize = self.view.bounds.size;
    
    self.makeDiscoverableDistanceFromTop.constant = mainViewSize.height/40;
    
    self.tableViewTopDistanceToView.constant = mainViewSize.height/16;
    
    self.makeDiscoverableLabel.adjustsFontSizeToFitWidth = YES;
    
    [super updateViewConstraints];
}


-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [self.appDelegate.multiPeerManager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self.appDelegate.multiPeerManager.browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    //if the session is NOT connecting
    if (state != MCSessionStateConnecting) {
        
        //if the state is connected then add the display name to the arrayList
        if (state == MCSessionStateConnected) {
            [[self.mainDataSource getConnectedDevices] addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){
            
            if ([self.mainDataSource getConnectedDevices].count > 0) {
                NSInteger indexOfPeer = [[self.mainDataSource getConnectedDevices] indexOfObject:peerDisplayName];
                [[self.mainDataSource getConnectedDevices] removeObjectAtIndex:indexOfPeer];
            }
            
        }
        
        [self.connectedDevicesTable reloadData];
        
        //does the number of connected peers = 0
        BOOL connectedPeers = ([self.appDelegate.multiPeerManager.peerSession connectedPeers].count == 0);
        
        self.disconnectButton.enabled = !connectedPeers;
        
    }
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.mainDataSource getConnectedDevices].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [[self.mainDataSource getConnectedDevices] objectAtIndex:indexPath.row];
    
    return cell;
}


//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60.0;
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
