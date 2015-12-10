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

#import <Bolts/BFTaskCompletionSource.h>
#import <Bolts/BFTask.h>
#import <Bolts/BFExecutor.h>
#import "ImojiSDK.h"
#import "NSDictionary+Utils.h"
#import "IMMutableImojiObject.h"
#import "UIImage+Extensions.h"
#import "IMMutableCategoryObject.h"
#import "BFTask+Utils.h"
#import "IMImojiSession+Private.h"
#import "IMArtist.h"
#import "IMMutableArtist.h"
#import "IMMutableCategoryAttribution.h"

NSString *const IMImojiSessionErrorDomain = @"IMImojiSessionErrorDomain";

@implementation IMImojiSession

@synthesize sessionState = _sessionState;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupWithStoragePolicy:[IMImojiSessionStoragePolicy temporaryDiskStoragePolicy]];
    }

    return self;
}

- (instancetype)initWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    self = [super init];
    if (self) {
        [self setupWithStoragePolicy:storagePolicy];
    }

    return self;
}

- (void)setupWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    _sessionState = IMImojiSessionStateNotConnected;

    _storagePolicy = storagePolicy;
    _fetchRenderingOptions = [IMImojiObjectRenderingOptions optionsWithRenderSize:IMImojiObjectRenderSizeThumbnail
                                                                      borderStyle:IMImojiObjectBorderStyleSticker
                                                                      imageFormat:IMImojiObjectImageFormatWebP];

    self->_urlSession = [NSURLSession sessionWithConfiguration:[_storagePolicy generateURLSessionConfiguration]];

    [self readAuthenticationCredentials];
}

- (BFTask *)downloadImojiContents:(IMMutableImojiObject *)imoji
                  renderingOtions:(IMImojiObjectRenderingOptions *)renderingOptions
                cancellationToken:cancellationToken {
    __block BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    [[self validateSession] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error) {
            taskCompletionSource.error = task.error;
        } else {
            if (!imoji.urls) {
                taskCompletionSource.error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                 code:IMImojiSessionErrorCodeImojiDoesNotExist
                                                             userInfo:@{
                                                                     NSLocalizedDescriptionKey : [NSString stringWithFormat:@"unable to download imoji %@", imoji.identifier]
                                                             }];
            } else {
                [[self downloadImojiImageAsync:imoji
                              renderingOptions:renderingOptions
                                    imojiIndex:0
                             cancellationToken:cancellationToken] continueWithExecutor:[BFExecutor mainThreadExecutor]
                                                                             withBlock:^id(BFTask *downloadTask) {
                                                                                 if (downloadTask.error) {
                                                                                     taskCompletionSource.error = downloadTask.error;
                                                                                 } else {
                                                                                     taskCompletionSource.result = downloadTask.result;
                                                                                 }

                                                                                 return nil;
                                                                             }];
            }
        }

        return nil;
    }];

    return taskCompletionSource.task;
}

#pragma mark Public Methods

- (NSOperation *)getImojiCategoriesWithClassification:(IMImojiSessionCategoryClassification)classification
                                             callback:(IMImojiSessionImojiCategoriesResponseCallback)callback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;
    __block NSString *classificationParameter = [IMImojiSession categoryClassifications][@(classification)];

    [[self runValidatedGetTaskWithPath:@"/imoji/categories/fetch"
                         andParameters:@{
                                 @"classification" : classificationParameter
                         }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;

        __block NSError *error;
        [self validateServerResponse:results error:&error];
        if (error) {
            callback(nil, error);
        } else {
            NSArray *categories = results[@"categories"];
            if (callback) {
                __block NSUInteger order = 0;

                if ([categories isEqual:[NSNull null]]) {
                    callback(nil, nil);
                } else {
                    NSMutableArray *imojiCategories = [NSMutableArray arrayWithCapacity:categories.count];

                    for (NSDictionary *dictionary in categories) {
                        NSDictionary *artistDictionary = dictionary[@"artist"];
                        IMMutableCategoryAttribution *attribution = nil;
                        if (![artistDictionary isEqual:[NSNull null]]) {
                            attribution = [IMMutableCategoryAttribution attributionWithIdentifier:[artistDictionary im_checkedStringForKey:@"packId"]
                                                                                           artist:[IMMutableArtist artistWithIdentifier:[artistDictionary im_checkedStringForKey:@"id"]
                                                                                                                                   name:[artistDictionary im_checkedStringForKey:@"name"]
                                                                                                                                summary:[artistDictionary im_checkedStringForKey:@"description"]
                                                                                                                           previewImoji:[self readImojiObject:artistDictionary]]
                                                                                              URL:[[NSURL alloc] initWithString:[artistDictionary im_checkedStringForKey:@"packURL"]]];
                        }

                        NSArray *imojisDictionary = [dictionary im_checkedArrayForKey:@"imojis"];
                        NSMutableArray *previewImojis = nil;
                        if (imojisDictionary) {
                            previewImojis = [[NSMutableArray alloc] init];
                            for (NSDictionary *imojiDictionary in imojisDictionary) {
                                [previewImojis addObject:[self readImojiObject:imojiDictionary]];
                            }
                        }

                        [imojiCategories addObject:[IMMutableCategoryObject objectWithIdentifier:[dictionary im_checkedStringForKey:@"searchText"]
                                                                                           order:order++
                                                                                    previewImoji:[self readImojiObject:dictionary]
                                                                                   previewImojis:previewImojis
                                                                                        priority:[dictionary im_checkedNumberForKey:@"priority" defaultValue:@0].unsignedIntegerValue
                                                                                           title:[dictionary im_checkedStringForKey:@"title"]
                                                                                     attribution:attribution]];
                    }

                    callback(imojiCategories, nil);
                }
            }
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)searchImojisWithTerm:(NSString *)searchTerm
                               offset:(NSNumber *)offset
                      numberOfResults:(NSNumber *)numberOfResults
            resultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (numberOfResults && numberOfResults.integerValue <= 0) {
        numberOfResults = nil;
    }

    if (offset && offset.integerValue < 0) {
        offset = nil;
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"query" : searchTerm != nil ? searchTerm : @"",
            @"numResults" : numberOfResults != nil ? numberOfResults : [NSNull null],
            @"offset" : offset != nil ? offset : @0
    }];

    [[self runValidatedGetTaskWithPath:@"/imoji/search" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;

        NSError *error;
        [self validateServerResponse:results error:&error];
        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                         relatedSearchTerm:[results im_checkedStringForKey:@"followupSearchTerm"]
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)getFeaturedImojisWithNumberOfResults:(NSNumber *)numberOfResults
                            resultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                                imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    id numResultsValue;
    if (numberOfResults && numberOfResults.integerValue <= 0) {
        numResultsValue = [NSNull null];
    } else {
        numResultsValue = numberOfResults != nil ? numberOfResults : [NSNull null];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"numResults" : numResultsValue
    }];

    [[self runValidatedGetTaskWithPath:@"/imoji/featured/fetch" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        if (getTask.error) {
            resultSetResponseCallback(nil, getTask.error);
            return nil;
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                         relatedSearchTerm:[results im_checkedStringForKey:@"followupSearchTerm"]
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)fetchImojisByIdentifiers:(NSArray *)imojiObjectIdentifiers
                  fetchedResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)fetchedResponseCallback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;
    if (!imojiObjectIdentifiers || imojiObjectIdentifiers.count == 0) {
        fetchedResponseCallback(nil, NSUIntegerMax, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                        code:IMImojiSessionErrorCodeInvalidArgument
                                                                    userInfo:@{
                                                                            NSLocalizedDescriptionKey : @"imojiObjectIdentifiers is either nil or empty"
                                                                    }]);
        return cancellationToken;
    }
    BOOL validArray = YES;
    for (id objectIdentifier in imojiObjectIdentifiers) {
        if (!objectIdentifier || ![objectIdentifier isKindOfClass:[NSString class]]) {
            validArray = NO;
            break;
        }
    }

    if (!validArray) {
        fetchedResponseCallback(nil, NSUIntegerMax, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                        code:IMImojiSessionErrorCodeInvalidArgument
                                                                    userInfo:@{
                                                                            NSLocalizedDescriptionKey : @"imojiObjectIdentifiers must contain NSString objects only"
                                                                    }]);
        return cancellationToken;
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"ids" : [imojiObjectIdentifiers componentsJoinedByString:@","]
    }];

    [[self runValidatedPostTaskWithPath:@"/imoji/fetchMultiple" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            fetchedResponseCallback(nil, NSUIntegerMax, error);
        } else {
            NSMutableArray *imojiObjects = [NSMutableArray arrayWithArray:[self convertServerDataSetToImojiArray:results]];

            [self handleImojiFetchResponse:imojiObjects
                         relatedSearchTerm:[results im_checkedStringForKey:@"followupSearchTerm"]
                         cancellationToken:cancellationToken
                    searchResponseCallback:nil
                     imojiResponseCallback:fetchedResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)searchImojisWithSentence:(NSString *)sentence
                          numberOfResults:(NSNumber *)numberOfResults
                resultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                    imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (numberOfResults && numberOfResults.integerValue <= 0) {
        numberOfResults = nil;
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
            @"sentence" : sentence,
            @"numResults" : numberOfResults != nil ? numberOfResults : [NSNull null]
    }];

    [[self runValidatedGetTaskWithPath:@"/imoji/search" andParameters:parameters] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        NSDictionary *results = getTask.result;

        NSError *error;
        [self validateServerResponse:results error:&error];
        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                         relatedSearchTerm:[results im_checkedStringForKey:@"followupSearchTerm"]
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)addImojiToUserCollection:(IMImojiObject *)imojiObject
                                 callback:(IMImojiSessionAsyncResponseCallback)callback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (self.sessionState != IMImojiSessionStateConnectedSynchronized) {
        callback(NO, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeSessionNotSynchronized
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : @"IMImojiSession has not been synchronized."
                                     }]);

        return cancellationToken;
    }

    [[self runValidatedPostTaskWithPath:@"/user/imoji/collection/add" andParameters:@{
            @"imojiId" : imojiObject.identifier
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            callback(NO, error);
        } else {
            callback(YES, nil);
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)getImojisForAuthenticatedUserWithResultSetResponseCallback:(IMImojiSessionResultSetResponseCallback)resultSetResponseCallback
                                                      imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (self.sessionState != IMImojiSessionStateConnectedSynchronized) {
        resultSetResponseCallback(nil, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                           code:IMImojiSessionErrorCodeSessionNotSynchronized
                                                       userInfo:@{
                                                               NSLocalizedDescriptionKey : @"IMImojiSession has not been synchronized."
                                                       }]);

        return cancellationToken;
    }

    [[self runValidatedGetTaskWithPath:@"/user/imoji/fetch" andParameters:@{}] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            resultSetResponseCallback(nil, error);
        } else {
            [self handleImojiFetchResponse:[self convertServerDataSetToImojiArray:results]
                         relatedSearchTerm:[results im_checkedStringForKey:@"followupSearchTerm"]
                         cancellationToken:cancellationToken
                    searchResponseCallback:resultSetResponseCallback
                     imojiResponseCallback:imojiResponseCallback];
        }

        return nil;
    }];

    return cancellationToken;
}

- (void)clearUserSynchronizationStatus:(IMImojiSessionAsyncResponseCallback)callback {
    [self renewCredentials:callback];
}

#pragma mark Imoji Modification

- (NSOperation *)createImojiWithRawImage:(UIImage *)image
                           borderedImage:(UIImage *)borderedImage
                                    tags:(NSArray *)tags
                     beginUploadCallback:(nonnull IMImojiSessionCreationResponseCallback)beginUploadCallback
                    finishUploadCallback:(nonnull IMImojiSessionCreationResponseCallback)finishUploadCallback {
    NSOperation *cancellationToken = self.cancellationTokenOperation;

    __block NSString *imojiId;
    __block IMImojiObject *localImoji;
    [[[[[self createLocalImojiWithRawImage:image
                             borderedImage:borderedImage
                                      tags:tags]
            continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
                localImoji = task.result;

                // trigger completion of the temporary imoji
                beginUploadCallback(localImoji, nil);

                // call the server to create a new imoji
                return [self runValidatedPostTaskWithPath:@"/imoji/create" andParameters:@{
                        @"tags" : tags != nil ? tags : [NSNull null]
                }];
            }]
            continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
                if (cancellationToken.cancelled) {
                    return [BFTask cancelledTask];
                }

                NSDictionary *results = getTask.result;
                NSError *error;
                [self validateServerResponse:results error:&error];

                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        finishUploadCallback(nil, error);
                    });

                    return error;
                }

                return results;
            }]
            continueWithSuccessBlock:^id(BFTask *task) {
                NSDictionary *response = (NSDictionary *) task.result;
                NSString *fullImageUrl = response[@"fullImageUrl"];

                imojiId = response[@"imojiId"];

                CGSize maxDimensions = CGSizeMake(
                        [(NSNumber *) response[@"fullImageResizeWidth"] floatValue],
                        [(NSNumber *) response[@"fullImageResizeHeight"] floatValue]
                );

                // start the upload
                return [self uploadImageInBackgroundWithRetries:[image im_resizedImageToFitInSize:maxDimensions scaleIfSmaller:NO]
                                                      uploadUrl:[NSURL URLWithString:fullImageUrl]
                                                     retryCount:3];
            }]
            continueWithBlock:
                    ^id(BFTask *task) {
                        if (task.error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                finishUploadCallback(nil, [NSError errorWithDomain:IMImojiSessionErrorDomain
                                                                              code:IMImojiSessionErrorCodeServerError
                                                                          userInfo:@{
                                                                                  NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Unable to upload imoji image"]
                                                                          }]);
                            });

                            return task.error;
                        }

                        // call the server once more to get the generated URL's for the new Imoji ID
                        [self fetchImojisByIdentifiers:@[imojiId]
                               fetchedResponseCallback:^(IMImojiObject *imoji, NSUInteger index, NSError *error) {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       finishUploadCallback(imoji, error);
                                   });
                               }];

                        return nil;
                    }];

    return cancellationToken;
}

- (NSOperation *)removeImoji:(IMImojiObject *)imojiObject
                    callback:(IMImojiSessionAsyncResponseCallback)callback {

    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    [[self runValidatedDeleteTaskWithPath:@"/imoji/remove" andParameters:@{
            @"imojiId" : imojiObject.identifier
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            callback(NO, error);
        } else {
            callback(YES, nil);
        }

        return nil;
    }];

    return cancellationToken;
}

- (NSOperation *)reportImojiAsAbusive:(IMImojiObject *)imojiObject
                               reason:(NSString *)reason
                             callback:(IMImojiSessionAsyncResponseCallback)callback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    [[self runValidatedPostTaskWithPath:@"/imoji/reportAbusive" andParameters:@{
            @"imojiId" : imojiObject.identifier,
            @"reason" : reason
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *getTask) {
        if (cancellationToken.cancelled) {
            return [BFTask cancelledTask];
        }

        NSDictionary *results = getTask.result;
        NSError *error;
        [self validateServerResponse:results error:&error];

        if (error) {
            callback(NO, error);
        } else {
            callback(YES, nil);
        }

        return nil;
    }];

    return cancellationToken;
}


#pragma mark Rendering

- (NSOperation *)renderImoji:(IMImojiObject *)imoji
                     options:(IMImojiObjectRenderingOptions *)options
                    callback:(IMImojiSessionImojiRenderResponseCallback)callback {
    __block NSOperation *cancellationToken = self.cancellationTokenOperation;

    if (!imoji || !imoji.identifier) {
        NSError *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeImojiDoesNotExist
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : @"Imoji is invalid"
                                         }];

        callback(nil, error);

        return cancellationToken;
    } else if (![imoji isKindOfClass:[IMMutableImojiObject class]]) {
        [self fetchImojisByIdentifiers:@[imoji.identifier]
               fetchedResponseCallback:^(IMImojiObject *internalImoji, NSUInteger index, NSError *error) {
                   if (cancellationToken.cancelled) {
                       return;
                   }

                   [self renderImoji:(IMMutableImojiObject *) internalImoji
                             options:options
                            callback:callback
                   cancellationToken:cancellationToken];
               }];
    } else {
        [self renderImoji:(IMMutableImojiObject *) imoji
                  options:options callback:callback
        cancellationToken:cancellationToken];
    }

    return cancellationToken;
}

- (void)renderImoji:(IMMutableImojiObject *)imoji
            options:(IMImojiObjectRenderingOptions *)options
           callback:(IMImojiSessionImojiRenderResponseCallback)callback
  cancellationToken:(NSOperation *)cancellationToken {

    IMImojiObjectRenderingOptions *requestedRenderingOptions = options;
    if (imoji.supportsAnimation && options.renderAnimatedIfSupported) {
        requestedRenderingOptions = [imoji supportedAnimatedRenderingOptionFromOption:options];
    }

    [[self downloadImojiContents:imoji
                 renderingOtions:requestedRenderingOptions
               cancellationToken:cancellationToken]
            continueWithBlock:^id(BFTask *task) {
                if (cancellationToken.cancelled) {
                    return [BFTask cancelledTask];
                }

                if (task.error) {
                    callback(nil, task.error);
                } else {
                    [BFTask im_serialBackgroundTaskWithBlock:^id(BFTask *bgTask) {
                        NSError *error;
                        UIImage *image = [self renderImoji:imoji
                                                   options:requestedRenderingOptions
                                                     image:task.result
                                                     error:&error];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!cancellationToken.cancelled) {
                                callback(image, error);
                            }
                        });

                        return nil;
                    }];
                }

                return nil;
            }];
}

- (UIImage *)renderImoji:(IMMutableImojiObject *)imoji
                 options:(IMImojiObjectRenderingOptions *)options
                   image:(UIImage *)image
                   error:(NSError **)error {

    CGSize targetSize = options.targetSize ? options.targetSize.CGSizeValue : CGSizeZero;
    CGSize aspectRatio = options.aspectRatio ? options.aspectRatio.CGSizeValue : CGSizeZero;
    CGSize maximumRenderSize = options.maximumRenderSize ? options.maximumRenderSize.CGSizeValue : CGSizeZero;

    if (image) {
        if (image.size.width == 0 || image.size.height == 0) {
            if (error) {
                *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                             code:IMImojiSessionErrorCodeInvalidImage
                                         userInfo:@{
                                                 NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Invalid image for imoji %@", imoji.identifier]
                                         }];
            }
            return nil;
        }

        if (targetSize.width <= 0 || targetSize.height <= 0) {
            targetSize = image.size;
        }

        // size the image appropriately for aspect enabled outputs, this allows the caller to specify a maximum
        // rendered image size with aspect
        if (!CGSizeEqualToSize(CGSizeZero, aspectRatio) && !CGSizeEqualToSize(CGSizeZero, maximumRenderSize)) {
            // get the potential size of the image with aspect
            CGSize targetSizeWithAspect = [image im_imageSizeWithAspect:aspectRatio];

            // scale down the size to whatever the caller specified
            if (targetSizeWithAspect.width > maximumRenderSize.width) {
                targetSizeWithAspect = CGSizeMake(maximumRenderSize.width, targetSizeWithAspect.height * maximumRenderSize.width / targetSizeWithAspect.width);
            } else if (maximumRenderSize.height > 0.0f && targetSizeWithAspect.height > maximumRenderSize.height) {
                targetSizeWithAspect = CGSizeMake(targetSizeWithAspect.width * maximumRenderSize.height / targetSizeWithAspect.height, maximumRenderSize.height);
            }

            // snap to either the max width or height of the aspect region and reset the shadow/border values appropriately
            if (image.size.width > targetSizeWithAspect.width) {
                targetSize = CGSizeMake(targetSizeWithAspect.width, targetSizeWithAspect.width);
            } else if (image.size.height > targetSizeWithAspect.height) {
                targetSize = CGSizeMake(targetSizeWithAspect.height, targetSizeWithAspect.height);
            }
        }

        // same size and ratio, no need to perform operations
        if (CGSizeEqualToSize(image.size, targetSize) && CGSizeEqualToSize(CGSizeZero, aspectRatio)) {
            return image;
        }

        if (image.images) {
            NSMutableArray *resizedFrames = [NSMutableArray new];
            for (UIImage *frame in image.images) {
                UIImage *resizedImage = CGSizeEqualToSize(targetSize, CGSizeZero) ? frame :
                        [frame im_resizedImageToFitInSize:targetSize scaleIfSmaller:YES];

                if (!CGSizeEqualToSize(CGSizeZero, aspectRatio)) {
                    resizedImage = [resizedImage im_imageWithAspect:aspectRatio];
                }

                [resizedFrames addObject:[resizedImage im_imageWithScreenScale]];
            }

            return [UIImage animatedImageWithImages:resizedFrames duration:image.duration];
        } else {
            UIImage *resizedImage = CGSizeEqualToSize(targetSize, CGSizeZero) ? image :
                    [image im_resizedImageToFitInSize:targetSize scaleIfSmaller:YES];

            if (!CGSizeEqualToSize(CGSizeZero, aspectRatio)) {
                resizedImage = [resizedImage im_imageWithAspect:aspectRatio];
            }

            resizedImage = [resizedImage im_imageWithScreenScale];

            return resizedImage;
        }
    } else {
        if (error) {
            *error = [NSError errorWithDomain:IMImojiSessionErrorDomain
                                         code:IMImojiSessionErrorCodeImojiDoesNotExist
                                     userInfo:@{
                                             NSLocalizedDescriptionKey : [NSString stringWithFormat:@"imoji %@ does not exist", imoji.identifier]
                                     }];
        }
    }

    return nil;
}

#pragma mark Static

+ (NSDictionary *)categoryClassifications {
    static NSDictionary *categoryClassifications = nil;
    static dispatch_once_t predicate;

    dispatch_once(&predicate, ^{
        categoryClassifications = @{
                @(IMImojiSessionCategoryClassificationTrending) : @"trending",
                @(IMImojiSessionCategoryClassificationGeneric) : @"generic",
                @(IMImojiSessionCategoryClassificationArtist) : @"artist",
                @(IMImojiSessionCategoryClassificationNone) : @"none"
        };
    });

    return categoryClassifications;
}

#pragma mark Initializers

+ (instancetype)imojiSession {
    return [[IMImojiSession alloc] init];
}

+ (instancetype)imojiSessionWithStoragePolicy:(IMImojiSessionStoragePolicy *)storagePolicy {
    return [[IMImojiSession alloc] initWithStoragePolicy:storagePolicy];
}

@end
