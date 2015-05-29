//
//  NoFilterClient.m
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 2/20/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NoFilterClient.h"
#import "NSData+NFExtensions.h"
#import "NSURL+Extension.h"
#import "AppDelegate.h"

@interface NoFilterClient () <NSURLSessionDelegate,NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
@property (strong,nonatomic) NSString *appKey;
@property (strong,nonatomic) NSString *appSecret;
@property (strong,nonatomic) NSURL *baseUrl;
@property (strong,nonatomic) NSString *token;
@property (strong,nonatomic) NSString *username;
@property (strong,nonatomic) NSString *password;
@property (strong,nonatomic) NSURLSession *dataSession;
@property (strong,nonatomic) NSOperationQueue *backgroundDownloadQueue;
@property (strong,nonatomic) NSURLSession *backgroundDownloadSession;
@end

typedef void (^ResultHandlerBlock)(BOOL);

static NSString *const NoFilterHostUrl = @"http://nofilter.pneumaticsystem.com";
static NSString *const BackgroundDownloadIdentifier = @"BackgroundDownloadIdentifier";
static BOOL tokenValid=NO;

@implementation NoFilterClient

+ (id)sharedClient {
    static NoFilterClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] init];
    });
    return sharedClient;
}

-(id)init {
    if ( self = [super init] ) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"NoFilterWeb" ofType:@"plist"];
        NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
        _appKey = plist[@"app_key"];
        _appSecret = plist[@"app_secret"];
        _baseUrl = [NSURL URLWithString:NoFilterHostUrl];
        
        //create the upload session
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        _dataSession = [NSURLSession sessionWithConfiguration:sessionConfig];
        
        //create the download session
        _backgroundDownloadQueue = [[NSOperationQueue alloc]init];
        _backgroundDownloadQueue.name = BackgroundDownloadIdentifier;
        
        NSURLSessionConfiguration *backgroundDownloadConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:BackgroundDownloadIdentifier];
        _backgroundDownloadSession = [NSURLSession sessionWithConfiguration:backgroundDownloadConfiguration delegate:self delegateQueue:_backgroundDownloadQueue];
        [self getNewAppToken];
    }
    return self;
}

-(void)registerNewUser:(NSString *)username withPassword:(NSString *)password {
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/user/create" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *usernameItem = [NSURLQueryItem queryItemWithName:@"username" value:username];
    NSURLQueryItem *passwordItem = [NSURLQueryItem queryItemWithName:@"password" value:password];
    NSURLQueryItem *tokenItem = [NSURLQueryItem queryItemWithName:@"token" value:self.token];
    
    urlComponents.queryItems = @[tokenItem,usernameItem,passwordItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *newDataTask = [self.dataSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        if(success){
            NSLog(@"Created new user:%@",username);
            [self loginUser:username withPassword:password];
        }
        else {
            NSLog(@"Unable to create new user:%@ %@",username,responseDict[@"error"]);
        }
        if((self.delegate!=nil)&&([self.delegate respondsToSelector:@selector(registerUserResult:)]))
            [self.delegate registerUserResult:success];
    }];
    
    [newDataTask resume];
}

-(void)loginUser:(NSString *)username withPassword:(NSString *)password {
    [self getNewUserToken:username withPassword:password withCompletionHandler:^(BOOL result) {
        if(result){
            self.username=username;
            self.password=password;
        }
       if((self.delegate!=nil)&&([self.delegate respondsToSelector:@selector(loginUserResult:)]))
          [self.delegate loginUserResult:result];
    }];
}

-(void)uploadPhoto:(Photo *)photo{
    [self validateToken];
    if(!tokenValid)
        [self getNewUserToken:self.username withPassword:self.password withCompletionHandler:nil];
    
    NSString *boundary = @"--boundary--";
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/item/create" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *tokenItem = [NSURLQueryItem queryItemWithName:@"token" value:self.token];
    urlComponents.queryItems = @[tokenItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    
    static NSDateFormatter *dateFormat = nil;
    if (nil == dateFormat) {
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    
    NSData *data = [photo.image multipartFormDataWithBoundaryString: boundary
                                                  preferredFilename: [NSString stringWithFormat:@"Image-%@.png",[dateFormat stringFromDate:[NSDate date]]]
                                                                                  contentType: @"image/png"];
    
    NSURLSessionUploadTask *newUploadTask = [self.dataSession uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        NSNumber *serverId = @-1;
        if(success){
            NSLog(@"Photo upload succeeded!");
            NSDictionary *resultDict = responseDict[@"result"];
            serverId = resultDict[@"id"];
        }
        else
            NSLog(@"Uable to upload photo! %@",responseDict[@"error"]);
        
        if((self.delegate!=nil)&&([self.delegate respondsToSelector:@selector(uploadPhotoResult:withId:)]))
            [self.delegate uploadPhotoResult:success withId:serverId];
    }];
    
    [newUploadTask resume];
}

-(void)getNewAppToken {
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/auth/token" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *appKeyItem = [NSURLQueryItem queryItemWithName:@"app_key" value:self.appKey];
    NSURLQueryItem *appSecretItem = [NSURLQueryItem queryItemWithName:@"app_secret" value:self.appSecret];
    
    urlComponents.queryItems = @[appKeyItem,appSecretItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *newDataTask = [self.dataSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        if(success){
            NSDictionary *resultDict = responseDict[@"result"];
            self.token = resultDict[@"token"];
            NSLog(@"New app token:%@",self.token);
            tokenValid=YES;
        }
        else {
            tokenValid=NO;
            NSLog(@"Uable to get app token! %@",responseDict[@"error"]);
        }
    }];
    
    [newDataTask resume];
}

-(void)getNewUserToken:(NSString *)username withPassword:(NSString *)password withCompletionHandler:(ResultHandlerBlock)resultHandler{
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/auth/token" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *usernameItem = [NSURLQueryItem queryItemWithName:@"username" value:username];
    NSURLQueryItem *passwordItem = [NSURLQueryItem queryItemWithName:@"password" value:password];
    NSURLQueryItem *appKeyItem = [NSURLQueryItem queryItemWithName:@"app_key" value:self.appKey];
    NSURLQueryItem *appSecretItem = [NSURLQueryItem queryItemWithName:@"app_secret" value:self.appSecret];
    
    urlComponents.queryItems = @[appKeyItem,appSecretItem,usernameItem,passwordItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *newDataTask = [self.dataSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        if(success){
            NSDictionary *resultDict = responseDict[@"result"];
            self.token = resultDict[@"token"];
            tokenValid=YES;
            if(resultHandler!=nil)
                resultHandler(YES);
        }
        else {
            if(resultHandler!=nil)
                resultHandler(NO);
            tokenValid=NO;
            NSLog(@"Uable to get user token! %@",responseDict[@"error"]);
        }
    }];
    
    [newDataTask resume];
}

-(void)validateToken {
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/auth/validate_token" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *tokenItem = [NSURLQueryItem queryItemWithName:@"token" value:self.token];
    
    urlComponents.queryItems = @[tokenItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *newDataTask = [self.dataSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        if(success){
            tokenValid=YES;
            NSLog(@"Token is valid!");
        }
        else {
            tokenValid=NO;
            NSLog(@"Token is not valid! %@",responseDict[@"error"]);
        }
    }];
    
    [newDataTask resume];
}

-(void)getServerList{
    [self validateToken];
    if(!tokenValid)
        [self getNewUserToken:self.username withPassword:self.password withCompletionHandler:nil];

    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/item/list" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *tokenItem = [NSURLQueryItem queryItemWithName:@"token" value:self.token];
    NSURLQueryItem *usernameItem = [NSURLQueryItem queryItemWithName:@"username" value:self.username];

    urlComponents.queryItems = @[tokenItem,usernameItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    
    NSURLSessionDataTask *newDataTask = [self.dataSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL success = [responseDict[@"success"] boolValue];
        if(success){
            NSLog(@"Got server list!");
            NSArray *resultArray = responseDict[@"result"];
            NSMutableArray *serverIdsArray = [[NSMutableArray alloc]init];
            for(NSDictionary *item in resultArray)
                [serverIdsArray addObject:item[@"id"]];
            if((self.delegate!=nil)&&([self.delegate respondsToSelector:@selector(serverListResult:)]))
                [self.delegate serverListResult:serverIdsArray];
        }
        else {
            NSLog(@"Don't got server list!");
        }
    }];
    
    [newDataTask resume];
}

-(void)downloadPhoto:(NSNumber*)serverId {
    [self validateToken];
    if(!tokenValid)
        [self getNewUserToken:self.username withPassword:self.password withCompletionHandler:nil];
    
    NSURL *endpoint = [NSURL URLWithString:@"/api/v1/item/get_raw" relativeToURL:self.baseUrl];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:endpoint resolvingAgainstBaseURL:YES];
    NSURLQueryItem *tokenItem = [NSURLQueryItem queryItemWithName:@"token" value:self.token];
    NSURLQueryItem *serverIdItem = [NSURLQueryItem queryItemWithName:@"item_id" value:[serverId stringValue]];
    
    urlComponents.queryItems = @[tokenItem,serverIdItem];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[urlComponents URL]];
    request.HTTPMethod = @"POST";
    NSURLSessionDownloadTask *downloadTask = [self.backgroundDownloadSession downloadTaskWithRequest:request];
    
    [downloadTask resume];
}

- (NSURL *)cachedImageURL:(NSNumber *)itemId{
    return [[[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                    inDomain:NSUserDomainMask
                                           appropriateForURL:nil
                                                      create:NO
                                                       error:NULL]
             URLByAppendingPathComponent:[itemId stringValue]]
            URLByAppendingPathExtension:@"png"];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if(location!=nil){
        NSURL *requestUrl = downloadTask.originalRequest.URL;
        NSNumber *serverId = [NSNumber numberWithInteger:[[requestUrl queryDictionary][@"item_id"] integerValue]];
        //NSLog(@"Downloaded to %@ for item id %@",location,serverId);
        if((self.delegate!=nil)&&([self.delegate respondsToSelector:@selector(downloadPhotoResult:withId:)])) {
            NSURL *cacheUrl = [self cachedImageURL:serverId];
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:cacheUrl error:NULL];
            //NSLog(@"Moved to %@ for item id %@",cacheUrl,serverId);
            [self.delegate downloadPhotoResult:cacheUrl withId:serverId];
        }
    }
    else {
        NSLog(@"Download failed!");
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil)
    {
        NSLog(@"Task %@ completed successfully", task);
    }
    else
    {
        NSLog(@"Task %@ completed with error: %@", task,error);
    }
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate.sessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.sessionCompletionHandler;
        appDelegate.sessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"Task complete");
}
                                              



@end
