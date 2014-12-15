//
//  CWWebServices.m
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/14/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import "CWWebServices.h"

NSString *const kWebServicesManagerContentUpdateNotification = @"com.carticipate.CapitolWords.WebServicesManagerMangerContentUpdate";

NSString *const kBaseApiURLString = @"http://capitolwords.org/api/1/";
NSString *const kDec2014TopWordsURLString    = @"https://api.github.com/users/steffenfrost/repos";

//NSString *const kDec2014TopWordsURLString    = @"http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201412&sort=count+desc&apikey=b7bb399593324f1da12c40977fc2598d";
NSString *const kDec2014Top100WordsURLString = @"http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201412&sort=count+desc&page=1&per_page=100apikey=b7bb399593324f1da12c40977fc2598d";


@interface CWWebServices ()
@property (nonatomic, strong) NSMutableArray *wordsArray;
@property (nonatomic, strong) dispatch_queue_t concurrentDownloadQueue;

@end

@implementation CWWebServices

- (instancetype) init {
    self = [super init];
    if (self) {
        self.wordsArray = [NSMutableArray array];
        self.concurrentDownloadQueue = dispatch_queue_create("com.carticipate.CapitolWords.downloadQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static CWWebServices *sharedWebServicesManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWebServicesManager = [[CWWebServices alloc] init];
    });
    
    return sharedWebServicesManager;
}

- (NSArray *)words
{
    __block NSArray *array;
    dispatch_sync(self.concurrentDownloadQueue, ^{
        array = _wordsArray;
    });
    return array;
}


- (void)downloadWordsWithCompletionBlock:(DownloadCompletionBlock)completionBlock
{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:configuration];
    });
    
    NSURL *url = [NSURL URLWithString:kDec2014TopWordsURLString];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            self.status = kWebServiceStatusSuccess;
            NSError *error;
            NSMutableDictionary *returnedDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            NSLog(@"The returned dictionary: %@", returnedDict);

        } else if (error){
            self.status = kWebServiceStatusFailed;
            NSLog(@"We errored: %@", error);
        }
        if (completionBlock) {
            completionBlock(error);
        }

        if (data) {
            // Convert the returned data into a dictionary.

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotification *notification = [NSNotification notificationWithName:kWebServicesManagerContentUpdateNotification object:nil];
            [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:nil];
        });
    }];
    
    [task resume];
}




@end
