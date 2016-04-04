//
//  ImojiSDK
//
//  Created by Alex Hoang
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
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KID, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@class IMImojiObject;

/**
 * @abstract Represents a creator of an Imoji or Category
 */
@interface IMArtist : NSObject

/**
 * @abstract Unique id for the artist
 */
@property(nonatomic, strong, readonly, nonnull) NSString *identifier;

/**
 * @abstract The name of the artist
 */
@property(nonatomic, strong, readonly, nonnull) NSString *name;

/**
 * @abstract Description of the artist
 */
@property(nonatomic, strong, readonly, nonnull) NSString *summary;

/**
 * @abstract An Imoji image representing the profile picture for the artist
 */
@property(nonatomic, strong, readonly, nullable) IMImojiObject *previewImoji;

@end
