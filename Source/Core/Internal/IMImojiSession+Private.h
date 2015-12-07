//
// Created by Nima on 7/29/15.
// Copyright (c) 2015 Imoji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMImojiSession.h"
#import "IMImojiObject.h"

@class IMImojiSessionCredentials;
@class IMMutableImojiObject;
@class BFTask;
@class IMImojiSessionStoragePolicy;

@interface IMImojiSession (Private)

#pragma mark Static

+ (nonnull IMImojiSessionCredentials *)credentials;

#pragma mark Auth

- (void)renewCredentials:(nonnull IMImojiSessionAsyncResponseCallback)callback;

- (void)readAuthenticationFromDictionary:(nonnull NSDictionary *)authenticationInfo;

- (void)readAuthenticationCredentials;

- (nonnull BFTask *)writeAuthenticationCredentials;

- (nonnull NSOperation *)cancellationTokenOperation;

#pragma mark Network Requests

- (nonnull BFTask *)runPostTaskWithPath:(nonnull NSString *)path headers:(nonnull NSDictionary *)headers andParameters:(nonnull NSDictionary *)parameters;

- (nonnull BFTask *)runValidatedGetTaskWithPath:(nonnull NSString *)path andParameters:(nonnull NSDictionary *)parameters;

- (nonnull BFTask *)runValidatedPutTaskWithPath:(nonnull NSString *)path andParameters:(nonnull NSDictionary *)parameters;

- (nonnull BFTask *)runValidatedPostTaskWithPath:(nonnull NSString *)path andParameters:(nonnull NSDictionary *)parameters;

- (nonnull BFTask *)runValidatedDeleteTaskWithPath:(nonnull NSString *)path andParameters:(nonnull NSDictionary *)parameters;

- (nonnull BFTask *)validateSession;

#pragma mark Network Responses

- (BOOL)validateServerResponse:(nonnull NSDictionary *)results error:(NSError *__nullable *__nullable)error;

- (nonnull NSArray *)convertServerDataSetToImojiArray:(nonnull NSDictionary *)serverResponse;

- (void)handleImojiFetchResponse:(nonnull NSArray *)imojiObjects
               relatedSearchTerm:(nonnull NSString *)relatedSearchTerm
               cancellationToken:(nonnull NSOperation *)cancellationToken
          searchResponseCallback:(nullable IMImojiSessionResultSetResponseCallback)searchResponseCallback
           imojiResponseCallback:(nullable IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (nonnull BFTask *)downloadImojiImageAsync:(nonnull IMMutableImojiObject *)imoji
                           renderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions
                                 imojiIndex:(NSUInteger)imojiIndex
                          cancellationToken:(nonnull NSOperation *)cancellationToken;

- (nonnull IMMutableImojiObject *)readImojiObject:(nonnull NSDictionary *)result;

- (nonnull BFTask *)uploadImageInBackgroundWithRetries:(nonnull UIImage *)image
                                             uploadUrl:(nonnull NSURL *)uploadUrl
                                            retryCount:(int)retryCount;

#pragma mark Session State Management

- (void)updateImojiState:(IMImojiSessionState)newState;

#pragma mark Imoji Creation

- (nonnull BFTask *)createLocalImojiWithRawImage:(nonnull UIImage *)rawImage
                                   borderedImage:(nonnull UIImage *)borderedImage
                                            tags:(nonnull NSArray *)tags;

- (void)removeLocalImoj:(nonnull IMImojiObject *)imoji;

- (nonnull BFTask *)writeImoji:(nonnull IMImojiObject *)imoji
              renderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions
                 imageContents:(nonnull NSData *)imageContents
                   synchronous:(BOOL)synchronous;

- (void)removeImoji:(nonnull IMImojiObject *)imoji
   renderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions;

- (nonnull NSString *)filePathFromImoji:(nonnull IMImojiObject *)imoji
                       renderingOptions:(nonnull IMImojiObjectRenderingOptions *)renderingOptions;


@end
