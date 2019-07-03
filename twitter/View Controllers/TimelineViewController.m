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
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            for (Tweet *tweet in tweets) {
                NSString *text = tweet.text;
                NSLog(@"%@", text);
            }
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

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
    cell.replyCount.text = [NSString stringWithFormat:@"%i", tweet.replyCount];
    cell.favoriteCount.text = [NSString stringWithFormat:@"%i", tweet.favoriteCount];
    cell.retweetCount.text = [NSString stringWithFormat:@"%i",tweet.retweetCount];
    
    NSString *profilePicString = tweet.user.imageUrl;
    NSURL *profilePicUrl = [NSURL URLWithString:profilePicString];
    
    [cell.profileImageView setImageWithURL:profilePicUrl];
    cell.profileImageView.layer.masksToBounds = true;
    cell.profileImageView.layer.cornerRadius = 40;
    
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




@end
