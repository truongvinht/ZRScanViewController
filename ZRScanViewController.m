/*
 
 ZRScanViewController.m
 
 Copyright (c) 22/02/2015 Truong Vinh Tran
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "ZRScanViewController.h"

// number of animations
#ifndef ZRSCANVC_NUMBERS_ANIMATION
#define ZRSCANVC_NUMBERS_ANIMATION 3
#endif

//default animation duration
#define ZRSCANVC_DURATION_ANIMATION 0.1f

@interface ZRScanViewController ()

/// target object to handle results
@property(nonatomic,weak) id<ZRScanViewControllerDelegate>delegate;

/// @name AVCapture Variables

/// session to capture
@property(nonatomic,strong) AVCaptureSession *captureSession;

/// layer for displaying background
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;

/// variable to delay input
@property(nonatomic,readwrite) BOOL skipInput;

/// image overlay for cursor
@property (weak, nonatomic) IBOutlet UIImageView *imageOverlay;

@end

@implementation ZRScanViewController


- (id)initWithDelegate:(id<ZRScanViewControllerDelegate>)target{
    self = [self initWithNibName:@"ZRScanViewController" bundle:nil];
    if (self) {
        self.delegate = target;
        self.recordDelay = 0.0f;
        self.skipInput = YES;
        self.overlayAlpha = 1;
        self.animateOverlay = NO;
        self.animationDuration = ZRSCANVC_DURATION_ANIMATION;
        
        self.codec = AVMetadataObjectTypeQRCode;
    }
    return self;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    //change orientation
    AVCaptureConnection *connection = self.previewLayer.connection;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:{
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            
        }break;
        case UIDeviceOrientationLandscapeRight:{
            connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            
        }break;
        case UIDeviceOrientationPortrait:{
            connection.videoOrientation = AVCaptureVideoOrientationPortrait;
            
        }break;
        case UIDeviceOrientationPortraitUpsideDown:{
            connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            
        }break;
        default:
            break;
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    [self stopScanning];
    [super viewDidDisappear:animated];
}

/** Method to setup the scanner for capture QR code*/
- (void)setupScanner{
    
    NSError *error;
        
    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    //catch error
    if (!deviceInput) {
        if (_delegate) {
            if ([_delegate respondsToSelector:@selector(zrScanViewController:didFailedScanning:)]) {
                [_delegate zrScanViewController:self didFailedScanning:error];
            }
        }
        return;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:deviceInput];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("captureQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:_codec]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:_previewView.layer.bounds];
    [_previewView.layer insertSublayer:_previewLayer atIndex:0];
    
    // Start video capture.
    [_captureSession startRunning];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _recordDelay * NSEC_PER_SEC),dispatch_get_main_queue(),^{
        self.skipInput = NO;
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupScanner];
    
    //update overlay
    if (_overlayImage) {
        [_imageOverlay setImage:_overlayImage];
        [_imageOverlay setAlpha:_overlayAlpha];
        
        
        //navigation controller (move the overlay image)
        if(self.navigationController){
            
            //remove old constraints
            NSMutableArray *oldConstraint = [NSMutableArray new];
            
            for(NSLayoutConstraint *con in _previewView.constraints){
                if (con.firstItem == _imageOverlay||con.secondItem == _imageOverlay) {
                    [oldConstraint addObject:con];
                }
            }
            
            [_previewView removeConstraints:oldConstraint];
            
            
            //add new constraints
            NSLayoutConstraint* topConstraint = [NSLayoutConstraint constraintWithItem:_imageOverlay
                                                                  attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0 constant:20];
            [self.view addConstraint:topConstraint];
            
            [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_imageOverlay
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_previewView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:10.0]];
            
            [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_imageOverlay
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_previewView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:-10.0]];
            
            [_previewView addConstraint:[NSLayoutConstraint constraintWithItem:_imageOverlay
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:_previewView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:-10.0]];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)stopScanning{
    if (_captureSession) {
        [_captureSession stopRunning];
        _captureSession = nil;
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //skip input for delay
    if (_skipInput) {
        return;
    }
    
    for(AVMetadataObject *current in metadataObjects) {
        if([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            if([self.delegate respondsToSelector:@selector(zrScanViewController:didFinishedScanning:)]) {
                NSString *scannedValue = [((AVMetadataMachineReadableCodeObject *) current) stringValue];
                [self.delegate zrScanViewController:self didFinishedScanning:scannedValue];
                
                //animate overlay
                if (_animateOverlay&&_imageOverlay) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:_animationDuration animations:^(void) {
                            for (int i=0; i < ZRSCANVC_NUMBERS_ANIMATION; i++) {
                                _imageOverlay.alpha = 0;
                                _imageOverlay.alpha = 1;
                            }
                        }];
                    });
                }
            }
        }
    }
}

@end
