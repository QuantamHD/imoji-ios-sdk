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
#import <UIKit/UIKit.h>
#import "IMImojiObjectRenderingOptions.h"

/**
* An ImojiObject is a reference to a sticker within the ImojiSDK. Consumers should not create this object directly,
* rather, they should use IMImojiSession to get them from the server.
*/
@interface IMImojiObject : NSObject

/**
* @abstract A unique identifier for the imoji. This field is never nil.
*/
@property(nonatomic, strong, readonly, nonnull) NSString *identifier;

/**
* @abstract One or more tags as NSString's. This field is never nil.
*/
@property(nonatomic, strong, readonly, nonnull) NSArray *tags;

/**
 * @abstract A dictionary representation of all the URL's of the Imoji images with IMImojiObjectRenderingOptions
 * as the key. Missing values will contain an NSNull value. Use getUrlForRenderingOptions: for convenience for
 * handling NSNull values.
 */
@property(nonatomic, strong, readonly, nonnull) NSDictionary *urls;

/**
 * @abstract Whether or not the Imoji has support for animation or not.
 */
@property(nonatomic, readonly) BOOL supportsAnimation;

/**
 * @abstract Gets a download URL for an Imoji given the requested rendering options
 */
- (nullable NSURL *)getUrlForRenderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions;

/**
 * @abstract Fetches rendering options suitable for an animated version of the Imoji. Returns nil if the Imoji
 * does not have a animated version available.
 */
- (nullable IMImojiObjectRenderingOptions *)supportedAnimatedRenderingOptionFromOption:(nonnull IMImojiObjectRenderingOptions *)renderingOptions;

@end
