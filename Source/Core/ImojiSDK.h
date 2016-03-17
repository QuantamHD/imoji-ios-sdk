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

#import <UIKit/UIKit.h>

////! Project version number for ImojiSDK.
//FOUNDATION_EXPORT double ImojiSDKVersionNumber;
//
////! Project version string for ImojiSDK.
//FOUNDATION_EXPORT const unsigned char ImojiSDKVersionString[];

#import <ImojiSDK/BFTask+Utils.h>
#import <ImojiSDK/NSDictionary+Utils.h>
#import <ImojiSDK/NSString+Utils.h>
#import <ImojiSDK/UIImage+Extensions.h>

#import <ImojiSDK/IMImojiSession+Private.h>
#import <ImojiSDK/IMImojiSession+Testing.h>
//#import <ImojiSDK/IMImojiSessionCredentials.h>
#import <ImojiSDK/IMMutableArtist.h>
#import <ImojiSDK/IMMutableCategoryAttribution.h>
#import <ImojiSDK/IMMutableCategoryObject.h>
#import <ImojiSDK/IMMutableImojiObject.h>
#import <ImojiSDK/ImojiSDKConstants.h>

#import <ImojiSDK/RequestUtils.h>

#import <ImojiSDK/IMArtist.h>
#import <ImojiSDK/IMCategoryAttribution.h>
#import <ImojiSDK/IMImojiObject.h>
#import <ImojiSDK/IMImojiCategoryObject.h>
#import <ImojiSDK/IMImojiObjectRenderingOptions.h>
#import <ImojiSDK/IMImojiResultSetMetadata.h>
#import <ImojiSDK/IMImojiSessionStoragePolicy.h>
#import <ImojiSDK/IMImojiSession.h>

#import <ImojiSDK/IMImojiApplicationUtility.h>
#import <ImojiSDK/IMImojiResultSetMetadata.h>
#import <ImojiSDK/ImojiSyncSDK.h>

/**
* @abstract Base class for coordinating with other ImojiSDK classes
*/
@interface ImojiSDK : NSObject

/**
* @abstract The version of the SDK
*/
@property(readonly, nonatomic, copy, nonnull) NSString *sdkVersion;

/**
* @abstract The clientId set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy, nonnull) NSUUID *clientId;

/**
* @abstract The apiToken set within setClientId:apiToken:
*/
@property(readonly, nonatomic, copy, nonnull) NSString *apiToken;

/**
* @abstract Singleton reference of the ImojiSDK object
*/
+ (nonnull ImojiSDK *)sharedInstance;

/**
* @abstract Sets the client identifier and api token. This should be called upon loading your application, typically
* in application:didFinishLaunchingWithOptions: in UIApplicationDelegate
* @param clientId The Client ID provided for you application
* @param apiToken The API token provided for you application
*/
- (void)setClientId:(NSUUID *__nonnull)clientId
           apiToken:(NSString *__nonnull)apiToken;

@end
