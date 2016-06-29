//
//  BLCMessageTestViewController.m
//  BlocTalk
//
//  Created by Inioluwa Work Account on 29/06/2016.
//  Copyright © 2016 Bloc. All rights reserved.
//

#import "BLCMessageTestViewController.h"
#import "BLCAppDelegate.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "BLCMultiPeerConnector.h"

@interface BLCMessageTestViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *messageToSendTextField;

@property (weak, nonatomic) IBOutlet UITextView *messageResponseTextView;


@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) BLCAppDelegate *appDelegate;

@end

@implementation BLCMessageTestViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.appDelegate = (BLCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.messageToSendTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDataWithNotificaion:) name:@"MCDidReceiveDataNotification" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)updateViewConstraints {
    
    
    [super updateViewConstraints];
    
}



-(void)sendMyMessage {
    
    NSData *dataToSend = [self.messageToSendTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = self.appDelegate.multiPeerManager.peerSession.connectedPeers;
    NSError *error;
    
    [self.appDelegate.multiPeerManager.peerSession sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.messageResponseTextView setText:[self.messageResponseTextView.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", self.messageToSendTextField.text]]];
    [self.messageToSendTextField setText:@""];
    [self.messageToSendTextField resignFirstResponder];
    
}


-(void)didReceiveDataWithNotificaion:(NSNotification *)notification {
    
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    [self.messageResponseTextView performSelectorOnMainThread:@selector(setText:) withObject:[self.messageResponseTextView.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
    
}


#pragma mark - IBActions


- (IBAction)sendButtonPressed:(id)sender {
    [self sendMyMessage];
}


- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.messageResponseTextView resignFirstResponder];
    [self.messageToSendTextField resignFirstResponder];
    
}


#pragma mark - UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMyMessage];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
