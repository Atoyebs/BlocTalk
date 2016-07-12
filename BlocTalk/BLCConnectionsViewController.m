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

@property (nonatomic, strong) NSMutableArray *kvoConnectedDevicesArray;

@end

@implementation BLCConnectionsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mainDataSource = [BLCDataSource sharedInstance];
    
    self.appDelegate = (BLCAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.appDelegate.multiPeerManager setupPeerAndSession];
    [self.appDelegate.multiPeerManager advertisePeer:self.makeDiscoverableSwitch.isOn];
    
    self.connectedDevicesTable.delegate = self;
    self.connectedDevicesTable.dataSource = self;
    
    self.kvoConnectedDevicesArray = [self.mainDataSource mutableArrayValueForKey:NSStringFromSelector(@selector(connectedDevices))];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:@"MCDidChangeStateNotification" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.connectedDevicesTable reloadData];
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
    
    [self.kvoConnectedDevicesArray removeAllObjects];
    
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
    [self.connectedDevicesTable reloadData];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [self.appDelegate.multiPeerManager.browser dismissViewControllerAnimated:YES completion:nil];
     [self.connectedDevicesTable reloadData];
}


//this is called when the state of any peer changes in relation to this peer
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification {
    
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    //if the session is NOT connecting
    if (state != MCSessionStateConnecting) {
        
        //if the state is connected then add the display name to the arrayList
        if (state == MCSessionStateConnected) {
            [self.kvoConnectedDevicesArray insertObject:peerID atIndex:0];
        }
        else if (state == MCSessionStateNotConnected){
            
            if ( [_kvoConnectedDevicesArray count] > 0) {
                [self.kvoConnectedDevicesArray removeObject:peerID];
            }
            
        }
        
        //does the number of connected peers = 0
        BOOL connectedPeers = (self.appDelegate.multiPeerManager.peerSession.connectedPeers.count == 0);
        
        self.disconnectButton.enabled = !connectedPeers;
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.connectedDevicesTable reloadData];
    });
    
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.kvoConnectedDevicesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    MCPeerID *currentPeerID = [self.kvoConnectedDevicesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentPeerID.displayName;
    
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
