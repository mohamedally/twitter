//
//  DetailsViewController.m
//  twitter
//
//  Created by mudi on 7/5/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "DetailsViewController.h"
#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "APIManager.h"

@interface DetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = self.tweet.user.screenName;
    self.bodyLabel.text = self.tweet.text;
    self.timestampLabel.text = self.tweet.createdAtString;
    [self.favButton setTitle:[NSString stringWithFormat:@"%i", self.tweet.favoriteCount] forState:UIControlStateNormal];
    [self.retweetButton setTitle:[NSString stringWithFormat:@"%i", self.tweet.retweetCount] forState:UIControlStateNormal];
    [self.replyButton setTitle:[NSString stringWithFormat:@"%i", self.tweet.replyCount] forState:UIControlStateNormal];
    
    NSInteger imageWidth = 56;
    self.profilePicture.layer.cornerRadius = imageWidth/2;
    
    
    NSString *profilePicString = self.tweet.user.imageUrl;
    NSURL *profilePicUrl = [NSURL URLWithString:profilePicString];
    
    [self.profilePicture setImageWithURL:profilePicUrl];
    self.profilePicture.layer.masksToBounds = true;
    
    if (self.tweet.favorited) {
        [self.favButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [self.favButton setImage:[UIImage imageNamed: @"favor-icon"] forState:UIControlStateNormal];
    }
    
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed: @"retweet-icon"] forState:UIControlStateNormal];
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapRetweet:(id)sender {
    if (self.tweet.retweeted) {
        self.tweet.retweeted = NO;
        self.tweet.retweetCount -= 1;
        
        [[APIManager shared] unRetweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error unretweeting tweet: %@", error.localizedDescription);
            }
            else  {
                [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
                [self refreshData];
            }
        }];
        
        
        
    } else {
        self.tweet.retweeted = YES;
        self.tweet.retweetCount += 1;
        
        [[APIManager shared] retweet:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error retweeting tweet: %@", error.localizedDescription);
            } else {
                [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
                [self refreshData];
            }
        }];
    }
}

- (IBAction)didTapLike:(id)sender {
    if (self.tweet.favorited) {
        self.tweet.favorited = NO;
        self.tweet.favoriteCount -= 1 ;
        
        [[APIManager shared] unFavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            } else {
                [self.favButton setImage:[UIImage imageNamed: @"favor-icon"] forState:UIControlStateNormal];
                [self refreshData];
                
            }
            
        }];
        
    } else {
        self.tweet.favorited = YES;
        self.tweet.favoriteCount += 1 ;
        
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            } else {
                [self.favButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
                [self refreshData];
            }
        }];
        
    }
    
}

- (void) refreshData {
    [self.favButton setTitle:[NSString stringWithFormat:@"%i", self.tweet.favoriteCount] forState:UIControlStateNormal];
    
    [self.retweetButton setTitle:[NSString stringWithFormat:@"%i", self.tweet.retweetCount] forState:UIControlStateNormal];
    
    
}




@end
