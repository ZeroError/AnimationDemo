//
//  ViewController.m
//  DownloadButtonAnimation
//
//  Created by  孟丰 on 17/2/14.
//  Copyright © 2017年  孟丰. All rights reserved.
//

#import "ViewController.h"
#import "DownloadButton.h"
@interface ViewController ()

@property (strong, nonatomic) DownloadButton *downloadButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloadButton = [[DownloadButton alloc] initWithFrame:CGRectMake(100, 100, 150, 150)];
    self.downloadButton.progressBarWidth  = 200;
    self.downloadButton.progressBarHeight = 30;
    [self.view addSubview:self.downloadButton];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
