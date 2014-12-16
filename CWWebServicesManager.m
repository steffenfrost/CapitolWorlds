//
//  CWWebServicesManager.m
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/14/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import "CWWebServicesManager.h"

NSString *const kWebServicesManagerContentUpdateNotification = @"com.carticipate.CapitolWords.WebServicesManagerMangerContentUpdate";

NSString *const kBaseApiURLString = @"http://capitolwords.org/api/1/";
NSString *const kDec2014TopWordsURLString    = @"https://api.github.com/users/steffenfrost/repos";

//NSString *const kDec2014TopWordsURLString    = @"http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201412&sort=count+desc&apikey=b7bb399593324f1da12c40977fc2598d";
NSString *const kDec2014Top100WordsURLString = @"http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201412&sort=count+desc&page=1&per_page=100apikey=b7bb399593324f1da12c40977fc2598d";


@interface CWWebServicesManager ()
@property (nonatomic, strong) NSMutableArray *wordsArray;
@property (nonatomic, strong) dispatch_queue_t concurrentDownloadQueue;

@end

@implementation CWWebServicesManager

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
    static CWWebServicesManager *sharedWebServicesManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedWebServicesManager = [[CWWebServicesManager alloc] init];
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
    
    __block NSError *error;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
        if (!taskError && data) {
            self.status = kWebServiceStatusSuccess;
        
            
            NSError *serializationError;
            NSMutableArray *returnedArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
            
            // Convert the returned data into a dictionary.
            if (!serializationError) {
                NSMutableArray *buildingArrayOfWords = [NSMutableArray array];
                for (NSDictionary *aRepo in returnedArray) {
                    NSLog(@"Repo: %@", aRepo);
                    CWWord *aWord = [[CWWord alloc] init];
                    aWord.word  = [aRepo objectForKey:@"name"];
                    NSLog(@"Count is: %@", [[aRepo objectForKey:@"size"] stringValue]);
                    aWord.count = [[aRepo objectForKey:@"size"] stringValue];
                    [buildingArrayOfWords addObject:aWord];
                }
                
                // Now do a thread safe write to our array
                dispatch_barrier_async(self.concurrentDownloadQueue, ^{
                    self.wordsArray = buildingArrayOfWords;
                });
            }
            else {
                error = serializationError;
            }
            

        } else if (taskError){
            self.status = kWebServiceStatusFailed;
            error = taskError;
            NSLog(@"We errored: %@", taskError);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotification *notification = [NSNotification notificationWithName:kWebServicesManagerContentUpdateNotification object:nil];
            [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostASAP coalesceMask:NSNotificationCoalescingOnName forModes:nil];
        });
    }];

    if (completionBlock) {
        completionBlock(error);
    }

    
    [task resume];
}




@end
