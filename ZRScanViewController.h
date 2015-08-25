/*
 
 ZQRScanViewController.h
 
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

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#ifndef ZRScanViewController__H
#define ZRScanViewController__H

@protocol ZRScanViewControllerDelegate;

/*! ViewController for displaying scanning QR Code*/
@interface ZRScanViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>

/// delay recording
@property(nonatomic,readwrite) double recordDelay;

/// view to display camera content
@property (weak, nonatomic) IBOutlet UIView *previewView;

/// overlay image for the scanner
@property(nonatomic,strong) UIImage *overlayImage;

/// alpha for overlay (default = 1.0)
@property(nonatomic,readwrite) double overlayAlpha;

/// animate overlay after successful scan (default off)
@property(nonatomic,readwrite) BOOL animateOverlay;

/// animation duration (default 0.1 Sec)
@property(nonatomic,readwrite) double animationDuration;

/// code which needs to be scanned (default QR)
@property (nonatomic, strong) NSString *codec;

/** Method to init a new instance of the QR scanner
 *  @param target is the target for scanning
 *  @return new instance of the QR scanner ViewController
 */
- (id)initWithDelegate:(id<ZRScanViewControllerDelegate>)target;

/** Method to stop the scanner*/
- (void)stopScanning;

@end

/*! Protocol for handling delegate call*/
@protocol ZRScanViewControllerDelegate <NSObject>

@optional

/** Method will be called after scanning was successful
 *  @param scanViewController is the scanner object
 *  @param scannedText is the text which was scanned
 */
- (void)zrScanViewController:(ZRScanViewController*)scanViewController didFinishedScanning:(NSString*)scannedText;

/** Method will be called after scanning was successful
 *  @param scanViewController is the scanner object
 *  @param error is the error object
 */
- (void)zrScanViewController:(ZRScanViewController *)scanViewController didFailedScanning:(NSError*)error;

@end

#endif