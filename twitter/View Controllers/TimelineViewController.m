//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "ComposeViewController.h"
#import "APIManager.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "DateTools.h"

// View controller becomes datasource and delegate of the tableView
@interface TimelineViewController () <ComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

// table view asks its dataSource for cellForRowAt and numberOfRows

// View controller has a tableView as a subView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *tweets;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *composeButton;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchTimeline];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchTimeline) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    
    
}

-(void) fetchTimeline {
    // Get timeline (API request)
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            // View controllers stores data passed into the completion handler
            self.tweets = tweets;
            
            //Reload the tableView
            [self.tableView reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];

}


//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 200;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UINavigationController *navigationController = [segue destinationViewController];
    ComposeViewController *composeController = (ComposeViewController*)navigationController.topViewController;
    composeController.delegate = self;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    Tweet* tweet = self.tweets[indexPath.row];
    cell.tweet = tweet;
    cell.nameLabel.text = tweet.user.name;
    cell.screenNameLabel.text = [@"@" stringByAppendingString:tweet.user.screenName];
    cell.dateLabel.text = tweet.createdAtString;
    cell.bodyLabel.text = tweet.text;
    
    
    NSString *timeAgo;
    NSDate *now = [NSDate date];
    NSDate *tweetDate = tweet.createdAtDate;
    long monthDiff = [now monthsFrom:tweetDate];
    long dayDiff = [now daysFrom:tweetDate];
    long hourDiff = [now hoursFrom:tweetDate];
    long minuteDiff = [now minutesFrom:tweetDate];
    long secondDiff = [now secondsFrom:tweetDate];
    
    if (monthDiff == 0){
        
        if (dayDiff != 0){
            timeAgo = [[NSString stringWithFormat:@"%lu", dayDiff] stringByAppendingString:@"d"];
        } else if (hourDiff != 0){
            timeAgo = [[NSString stringWithFormat:@"%lu", hourDiff] stringByAppendingString:@"h"];
        } else if (minuteDiff != 0){
            timeAgo = [[NSString stringWithFormat:@"%lu", minuteDiff] stringByAppendingString:@"m"];
        } else {
            timeAgo = [[NSString stringWithFormat:@"%lu", secondDiff] stringByAppendingString:@"s"];
        }
        
        cell.dateLabel.text = timeAgo;
    }
    
    [cell.likeButton setTitle:[NSString stringWithFormat:@"%i", tweet.favoriteCount] forState:UIControlStateNormal];
    [cell.retweetButton setTitle:[NSString stringWithFormat:@"%i", tweet.retweetCount] forState:UIControlStateNormal];
    [cell.replyButton setTitle:[NSString stringWithFormat:@"%i", tweet.replyCount] forState:UIControlStateNormal];
    
    NSString *profilePicString = tweet.user.imageUrl;
    NSURL *profilePicUrl = [NSURL URLWithString:profilePicString];
    
    [cell.profileImageView setImageWithURL:profilePicUrl];
    cell.profileImageView.layer.masksToBounds = true;
    
    NSInteger imageWidth = 56;
    cell.profileImageView.layer.cornerRadius = imageWidth/2;
    
    if (tweet.favorited) {
        [cell.likeButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [cell.likeButton setImage:[UIImage imageNamed: @"favor-icon"] forState:UIControlStateNormal];
    }
    
    if (tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed: @"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [cell.retweetButton setImage:[UIImage imageNamed: @"retweet-icon"] forState:UIControlStateNormal];
    }
    
    // cellForRowAt returns an instance of the custom cell with that reuse identifier with its elements populated with data at the index asked for
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //  number of rows returns the number of items returned from the API
    return self.tweets.count;
}

- (void)didTweet:(nonnull Tweet *)tweet {
    [self.tweets insertObject: tweet atIndex:0];
    [self.tableView reloadData];
}

- (IBAction)logOutTapped:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}



@end
