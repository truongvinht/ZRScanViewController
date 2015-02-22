# ZRScanViewController
An Objective-C custom ViewController to scan codes (e.g. QR) using AVFoundation (Requires iOS 7 or higher)

#Example
To Scan QR-Codes:


```Objective-C
ZRScanViewController *scanner = [[ZRScanViewController alloc] initWithDelegate:self];

// image for overlay
scanner.overlayImage = [UIImage imageNamed:@"cursor"]; 
scanner.overlayAlpha = 0.7; 

//start recording after 5 seconds
scanner.recordDelay = 5; 

//title of the view
scanner.title = @"Scanning"; 
[self.navigationController pushViewController:scanner animated:YES];
```

To handle result implement the protocol ZRScanViewControllerDelegate and the method 

```Objective-C
- (void)zrScanViewController:(ZRScanViewController*)scanViewController didFinishedScanning:(NSString*)scannedText;
```
#License
MIT License (MIT)