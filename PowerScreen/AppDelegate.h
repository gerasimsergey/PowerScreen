//
//  AppDelegate.h
//  PowerScreen
//
//  Created by Andrew James on 29/11/2014.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import Foundation;
#import "ORSSerialPortManager.h"
#import "ORSSerialPort.h"


NSString *recieveBuffer;

@interface AppDelegate : NSObject <ORSSerialPortDelegate>



@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *serialPort;
-(void)sendCommand:(NSString *)command;
-(ORSSerialPort *)findSerialPortWithName:(NSString *)portName;
-(void)startConnection;
-(IBAction)sendAction:(id)sender;
@end

