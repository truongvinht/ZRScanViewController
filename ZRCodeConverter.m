/*
 
 ZRCodeConverter.m
 
 Copyright (c) 14/03/2015 Truong Vinh Tran
 
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

#import "ZRCodeConverter.h"

#define ZRCODE_DEFAULT_SIZE 250.0f

@interface ZRCodeConverter()

/// string which is used for converting
@property(nonatomic,strong) NSString *inputString;

@end

@implementation ZRCodeConverter


- (ZRCodeConverter*)initWithCode:(NSString*)code{
    self = [super init];
    
    if (self) {
        //init string
        self.inputString = code;
        
        //init default settings
        self.encoding = NSUTF8StringEncoding;
        self.errorLevel = ZRCodeErrorResilienceLevelL;
        self.size = ZRCODE_DEFAULT_SIZE;
    }
    return self;
}


- (UIImage*)convertToType:(ZRCodeConverterType)type{
    
    //QR Code image
    if (type==ZRCodeConverterTypeQR) {
        
        // Need to convert the string to target encoded NSData object
        NSData *stringData = [_inputString dataUsingEncoding:_encoding];
        
        // Create the filter to convert string to QR image
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        [qrFilter setDefaults];
        
        // Set the message content and error-correction level
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        
        //set error input correction
        switch (_errorLevel) {
            case ZRCodeErrorResilienceLevelH:
                [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
                break;
            case ZRCodeErrorResilienceLevelL:
                [qrFilter setValue:@"L" forKey:@"inputCorrectionLevel"];
                break;
            case ZRCodeErrorResilienceLevelM:
                [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
                break;
            case ZRCodeErrorResilienceLevelQ:
                [qrFilter setValue:@"Q" forKey:@"inputCorrectionLevel"];
                break;
            default:
                [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
                break;
        }
        
        return [self createNonInterpolatedUIImageFromCIImage:qrFilter.outputImage withSize:_size];
    }
    
    
    
    
    
    
    return nil;
}

/** Method to scale image
 *  @param image is the input image
 *  @param scale is the value for resizing image
 *  @return scaled image
 */
- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withSize:(CGFloat)size
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(size, size));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    CGContextRotateCTM(context, 1.5707964);
    
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    scaledImage = [UIImage imageWithCGImage:cgImage scale:size orientation:UIImageOrientationUp];
    
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    return scaledImage;
}

@end
