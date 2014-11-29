//
//  AppDelegate.m
//  PowerScreen
//
//  Created by Andrew James on 29/11/2014.
//  Copyright (c) 2014 Andrew James. All rights reserved.
//

id App;

#import "AppDelegate.h"


void displayPowerNotificationsCallback(void *refcon, io_service_t service, natural_t messageType, void *messageArgument)
{
    switch (messageType) {
        case kIOMessageDeviceWillPowerOff :
            [App sendCommand:@"SWITCH 2 OFF"];
            break;
        case kIOMessageDeviceHasPoweredOn :
            [App sendCommand:@"SWITCH 2 ON"];
            break;
    }
}
@interface AppDelegate ()

@end

@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // Doesn't include error checking - just a quick example
        io_service_t displayWrangler;
        IONotificationPortRef notificationPort;
        io_object_t notification;
        
        displayWrangler = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceNameMatching("IODisplayWrangler"));
        notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
        IOServiceAddInterestNotification(notificationPort, displayWrangler, kIOGeneralInterest, displayPowerNotificationsCallback, NULL, &notification);
        
        CFRunLoopAddSource (CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notificationPort), kCFRunLoopDefaultMode);
        IOObjectRelease (displayWrangler);
        App = self;
        
        
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
        [nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
        
        recieveBuffer = @""; //Start with blank buffer
        
        [self startConnection];
        
    }
    return self;
}

- (void)serialPortsWereConnected:(NSNotification *)notification
{
    NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
    NSLog(@"Ports were connected: %@", connectedPorts);
    [self startConnection];
}

-(void)startConnection{
    NSLog(@"Starting connection");
    //if (self.serialPort.isOpen) {
        //NSLog(@"Closing existing port");
        //[self.serialPort close];
        //self.serialPort = nil;
    //}
    //if (self.serialPort == nil) {
        self.serialPort = [self findSerialPortWithName:@"usbmodem"];
        self.serialPort.baudRate = @9600;
        [self.serialPort open];
        if (self.serialPort.isOpen) { NSLog(@"Opened port named: %@", self.serialPort.name); }
    //} else {
     //  NSLog(@"Port is already open");
  // }
    //NSLog(@"Should of connected by now!");
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
    NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
    NSLog(@"Ports were disconnected: %@", disconnectedPorts);
    //[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
    
}


-(IBAction)sendAction:(id)sender {
    NSLog(@"Sending action");
    [self sendCommand:@"DOOR STATUS"];
}



-(ORSSerialPort *)findSerialPortWithName:(NSString *)portName {
    for (id object in self.serialPortManager.availablePorts) {
        if ([[object name] rangeOfString:portName].location != NSNotFound) {
            NSLog(@"Found port");
            return object;
        }
    }
    NSLog(@"Failed to find port!");
    return nil;
}

-(void)sendCommand:(NSString *)command{
    if (self.serialPort.isOpen) {
        NSLog(@"Sending command: %@", command);
        NSData *dataToSend = [[NSString stringWithFormat:@"%@\n", command] dataUsingEncoding:NSUTF8StringEncoding];
        [self.serialPort sendData:dataToSend];
    } else {
        NSLog(@"Port is not open!");
    }
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSArray *ports = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
    for (ORSSerialPort *port in ports) { [port close]; }
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([string length] == 0) return;
    NSLog(@"Data recieved %@", string);
//    if ([string rangeOfString:@"\n"].location != NSNotFound) {
//        NSLog(@"%@", recieveBuffer);
//        recieveBuffer = @"";
//    } else {
//        recieveBuffer = [NSString stringWithFormat:@"%@%@", recieveBuffer, string];
//        
//    }
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
    // After a serial port is removed from the system, it is invalid and we must discard any references to it
    NSLog(@"Removing serial port");
    [serialPort close];
    self.serialPort = nil;
    //self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}


- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    //self.openCloseButton.title = @"Close";
    NSLog(@"Close");
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    NSLog(@"Open");
    //self.openCloseButton.title = @"Open";
}

@end
