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
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

@class IMArtist;

/**
* @abstract Describes the type of attribution URL
*/
typedef NS_ENUM(NSUInteger, IMAttributionURLCategory) {
    /**
     * @abstract The provided URL will link to a website.
     */
            IMAttributionURLCategoryWebsite,

    /**
     * @abstract The provided URL will link to an Instagram profile page.
     */
            IMAttributionURLCategoryInstagram,

    /**
     * @abstract The provided URL will link to a video (ex: Youtube, Vimeo, etc).
     */
            IMAttributionURLCategoryVideo,

    /**
     * @abstract The provided URL will link to a Twitter Profile page.
     */
            IMAttributionURLCategoryTwitter,

    /**
     * @abstract The provided URL will link to a landing page in the Apple App Store.
     */
            IMAttributionURLCategoryAppStore
};


/**
*  @abstract Represents the attribution of the category.
*/
@interface IMCategoryAttribution : NSObject

/**
 * @abstract A unique id for the attribution record.
 */
@property(nonatomic, strong, readonly, nonnull) NSString *identifier;

/**
 * @abstract The artist/contributor information.
 */
@property(nonatomic, strong, readonly, nonnull) IMArtist *artist;

/**
 * @abstract URL for the attribution.
 */
@property(nonatomic, strong, readonly, nonnull) NSURL *URL;

/**
 * @abstract Classification of the URL.
 */
@property(nonatomic) IMAttributionURLCategory urlCategory;

/**
 * @abstract One or more searchable tags that’s relevant to the attribution.
 */
@property(nonatomic, nullable) NSArray *relatedTags;

@end
