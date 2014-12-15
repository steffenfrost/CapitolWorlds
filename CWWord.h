//
//  CWWord.h
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/14/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWWord : NSObject

@property (nonatomic, strong) NSString *count; // key: "count"
@property (nonatomic, strong) NSString *word;  // key: "ngram"

@end
