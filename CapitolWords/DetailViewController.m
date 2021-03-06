//
//  DetailViewController.m
//  CapitolWords
//
//  Created by Steven Frost-Ruebling on 12/8/14.
//  Copyright (c) 2014 Carticipate, Inc. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        CWWord *aWord = (CWWord*)self.detailItem;
        self.detailDescriptionLabel.text = aWord.word;
        self.detailCountLabel.text       = aWord.count;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
