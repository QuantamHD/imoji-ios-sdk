//
//  ImojiSDK
//
//  Created by Nima Khoshini
//  Copyright (C) 2015 Imoji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

/**
* @abstract Specifies the imoji image quality to use for rendering.
*/
typedef NS_ENUM(NSUInteger, IMImojiObjectRenderSize) {
    /**
    * @abstract When used, a compressed version of the Imoji is downloaded and rendered. This setting is useful when
    * the consumer wishes to load and display multiple imojis as fast as possible. Sizes of the thumbnail imojis vary
    * but do not exceed 150x150 pixels
    */
            IMImojiObjectRenderSizeThumbnail,

    /**
    * @abstract When used, a high resolution image of the Imoji is downloaded and rendered. This setting is useful when
    * the consumer wishes to export the imoji to another application or to simply display a large version of it.
    */
            IMImojiObjectRenderSizeFullResolution,

    /**
    * @abstract Renders an Imoji image with a maximum dimension of 320x320 pixels. Ideal for high resolution
     * large displays in which the thumbnail size lacks the desired quality.
    */
            IMImojiObjectRenderSize320,

    /**
    * @abstract Renders an Imoji image with a maximum dimension of 512x512 pixels.
    */
            IMImojiObjectRenderSize512
};

typedef NS_ENUM(NSUInteger, IMImojiObjectBorderStyle) {
    /**
    * @abstract The default option for rendering Imoji images. Results will show a white border with a small
     * gray shadow like a sticker.
    */
            IMImojiObjectBorderStyleSticker,

    /**
    * @abstract When used, the Imoji image will have no border.
    */
            IMImojiObjectBorderStyleNone
};

typedef NS_ENUM(NSUInteger, IMImojiObjectImageFormat) {
    /**
     * @abstract PNG photo format. Using this results is larger file sizes.
     */
            IMImojiObjectImageFormatPNG,

    /**
     * @abstract WebP photo format. Using this results in smaller file sizes with minimal quality degradation.
     */
            IMImojiObjectImageFormatWebP
};

/**
* @abstract Defines multiple options for rendering IMImojiObjects to images
*/
@interface IMImojiObjectRenderingOptions : NSObject<NSCopying>

/**
* @abstract The desired size of the image to load. For best performance, use IMImojiObjectRenderSizeThumbnail. For
* highest quality, use IMImojiObjectRenderSizeFullResolution
*/
@property(nonatomic) IMImojiObjectRenderSize renderSize;

/**
* @abstract The desired size to scale the IMImojiObject to.
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong, nullable) NSValue *targetSize;

/**
* @abstract The maximum bounding size to render the IMImojiObject to. When setting options such as aspectRatio,
* the overall size of the image may grow quite large depending on the aspect. Use this option to limit the growth.
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong, nullable) NSValue *maximumRenderSize;

/**
* @abstract An optional aspect ratio to fit the image into when rendering. The height or width is padded appropriately to
* accommodate to the desired aspect
* The content of the NSValue object is a CGSize struct
* @see [NSValue valueWithCGSize:](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSValue_Class/index.html#//apple_ref/occ/clm/NSValue/valueWithCGSize:)
*/
@property(nonatomic, strong, nullable) NSValue *aspectRatio;

/**
* @abstract The desired border style. Defaults to IMImojiObjectBorderStyleSticker.
*/
@property(nonatomic) IMImojiObjectBorderStyle borderStyle;

/**
* @abstract The desired image format (used for optimizing downloading sizes). Defaults to IMImojiObjectImageFormatWebP.
*/
@property(nonatomic) IMImojiObjectImageFormat imageFormat;

+ (nonnull instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize;

+ (nonnull instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                                  borderStyle:(IMImojiObjectBorderStyle)borderStyle;

+ (nonnull instancetype)optionsWithRenderSize:(IMImojiObjectRenderSize)renderSize
                                  borderStyle:(IMImojiObjectBorderStyle)borderStyle
                                  imageFormat:(IMImojiObjectImageFormat)imageFormat;

@end
