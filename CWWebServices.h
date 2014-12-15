//
//  CWWebServices.h
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/14/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "CWWord.h"

/// Notification when content updates (i.e. Download finishes)
extern NSString *const kWebServicesManagerContentUpdateNotification;

typedef void (^DownloadCompletionBlock)(NSError *error);

typedef NS_ENUM(NSInteger, WebServiceStatus) {
    kWebServiceStatusDownloading, // 0 - still downloading
    kWebServiceStatusSuccess,     // 1 - success
    kWebServiceStatusFailed,      // 2 - failed download
};


@interface CWWebServices : NSObject
@property (nonatomic, assign) WebServiceStatus status; // Redeclare status as writeable.

+ (instancetype)sharedManager;

- (NSArray *)words;
- (void)downloadWordsWithCompletionBlock:(DownloadCompletionBlock)completionBlock;


@end

// What we are going for
// http://capitolwords.org/api/1/phrases.json?entity_type=month&entity_value=201007&sort=count+desc&apikey=b7bb399593324f1da12c40977fc2598d
//Results
//Returns a list of phrases with tf-idf and count data
/*
[
 {
     "tfidf": 3.8596557124800003e-05,
     "count": 5373,
     "ngram": "people"
 },
 {
     "tfidf": 1.30267768302e-05,
     "count": 3637,
     "ngram": "one"
 },
 {
     "tfidf": 2.52066478599e-05,
     "count": 3509,
     "ngram": "jobs"
 },
 {
     "tfidf": 1.17409333103e-05,
     "count": 3278,
     "ngram": "american"
 },
 ...
 ]
*/
