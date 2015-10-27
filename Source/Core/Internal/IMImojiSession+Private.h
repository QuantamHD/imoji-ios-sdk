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

+ (IMImojiSessionCredentials *)credentials;

+ (NSURLSession *)downloadURLSession;

+ (NSURLSession *)uploadInBackgroundURLSession;

#pragma mark Auth

- (void)renewCredentials:(IMImojiSessionAsyncResponseCallback)callback;

- (void)readAuthenticationFromDictionary:(NSDictionary *)authenticationInfo;

- (void)readAuthenticationCredentials;

- (BFTask *)writeAuthenticationCredentials;

- (NSOperation *)cancellationTokenOperation;

#pragma mark Network Requests

- (BFTask *)runPostTaskWithPath:(NSString *)path headers:(NSDictionary *)headers andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedGetTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedPutTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedPostTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)runValidatedDeleteTaskWithPath:(NSString *)path andParameters:(NSDictionary *)parameters;

- (BFTask *)validateSession;

#pragma mark Network Responses

- (BOOL)validateServerResponse:(NSDictionary *)results error:(NSError **)error;

- (NSArray *)convertServerDataSetToImojiArray:(NSDictionary *)serverResponse;

- (void)handleImojiFetchResponse:(NSArray *)imojiObjects
                renderingOptions:(IMImojiObjectRenderingOptions *)renderingOptions
               cancellationToken:(NSOperation *)cancellationToken
          searchResponseCallback:(IMImojiSessionResultSetResponseCallback)searchResponseCallback
           imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (void)downloadImojiImageAsync:(IMMutableImojiObject *)imoji
               renderingOptions:(IMImojiObjectRenderingOptions *)renderingOptions
                     imojiIndex:(NSUInteger)imojiIndex
              cancellationToken:(NSOperation *)cancellationToken
          imojiResponseCallback:(IMImojiSessionImojiFetchedResponseCallback)imojiResponseCallback;

- (IMMutableImojiObject *)readImojiObject:(NSDictionary *)result;

- (BFTask *)uploadImageInBackgroundWithRetries:(UIImage *)image
                                     uploadUrl:(NSURL *)uploadUrl
                                    retryCount:(int)retryCount;

#pragma mark Session State Management

- (void)updateImojiState:(IMImojiSessionState)newState;

#pragma mark Imoji Creation

- (BFTask *)createLocalImojiWithRawImage:(UIImage *)rawImage
                           borderedImage:(UIImage *)borderedImage
                                    tags:(NSArray *)tags;

- (void)removeLocalImoj:(IMImojiObject *)imoji;

@end
