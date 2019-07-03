//
//  TweetCell.m
//  twitter
//
//  Created by mudi on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "TweetCell.h"
#import "APIManager.h"

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapFavorite:(id)sender {
    
    if (self.tweet.favorited) {
        self.tweet.favorited = NO;
        self.tweet.favoriteCount -= 1 ;
        
        [[APIManager shared] unFavorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
        }];
        
        [self refereshData];
        [self.likeButton setImage:[UIImage imageNamed: @"favor-icon"] forState:UIControlStateNormal];
        
    } else {
        self.tweet.favorited = YES;
        self.tweet.favoriteCount += 1 ;
        
        [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
            if(error){
                NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
            }
        }];
        
        [self refereshData];
        [self.likeButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
    }
//    self.tweet.favorited = YES;
//    self.tweet.favoriteCount += 1 ;
//
//    [[APIManager shared] favorite:self.tweet completion:^(Tweet *tweet, NSError *error) {
//        if(error){
//            NSLog(@"Error favoriting tweet: %@", error.localizedDescription);
//        }
//        else{
//            NSLog(@"Successfully favorited the following Tweet: %@", tweet.text);
//        }
//    }];
//
//    [self refereshData];
//    [self.likeButton setImage:[UIImage imageNamed: @"favor-icon-red"] forState:UIControlStateNormal];
}

- (void) refereshData {
    self.favoriteCount.text = [NSString stringWithFormat:@"%i", self.tweet.favoriteCount];
}

@end
