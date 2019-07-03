//
//  ComposeViewController.m
//  twitter
//
//  Created by mudi on 7/2/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "ComposeViewController.h"
#import "APIManager.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *composeTweetView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tweetButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
- (IBAction)closeTweetComposer:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)postTweet:(id)sender {
    [[APIManager shared] postStatusWithText:_composeTweetView.text completion:^(Tweet *tweet, NSError *error) {
        if(tweet) {
             [self.delegate didTweet:tweet];
            [self dismissViewControllerAnimated:true completion:nil];
            NSLog(@"Successfully posted a tweet");
        } else {
            NSLog(@"😫😫😫 Error posting tweet: %@", error.localizedDescription);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
