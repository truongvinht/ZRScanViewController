/*
 
 ZRCodeConverter.h
 
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

#ifndef ZRCODE_CONVERTER__H
#define ZRCODE_CONVERTER__H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>

///enum type for converting code to image
typedef enum{
    /// QR Code
    ZRCodeConverterTypeQR
}ZRCodeConverterType;

///QR Error resilience
typedef enum{
    /// 30% error resilience
    ZRCodeErrorResilienceLevelH,
    /// 25% error resilience
    ZRCodeErrorResilienceLevelQ,
    /// 15% error resilience
    ZRCodeErrorResilienceLevelM,
    /// 7% error resilience
    ZRCodeErrorResilienceLevelL
}ZRCodeErrorResilienceLevel;

/*! Class to convert code to image for visualisation*/
@interface ZRCodeConverter : NSObject

/// input encoding (default:NSUTF8StringEncoding)
@property(nonatomic) NSStringEncoding encoding;

/// error resilience level for QR (default:Level L)
@property(nonatomic,readwrite) ZRCodeErrorResilienceLevel errorLevel;

/// size of the image - width and height (default = 250)
@property(nonatomic,readwrite) CGFloat size;

/** Method to init a new instance to convert given code
 *  @param code is the input which needs to be converted
 *  @return new instance
 */
- (ZRCodeConverter*)initWithCode:(NSString*)code;


/** Method to get the converted image using target type
 *  @param type is the target type
 *  @return image for given type and code, nil if type is not known
 */
- (UIImage*)convertToType:(ZRCodeConverterType)type;

@end

#endif