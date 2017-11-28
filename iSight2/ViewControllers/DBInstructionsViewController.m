//
//  DBInstructionsViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

@import AVFoundation;
@import AVKit;

#import "DBInstructionsViewController.h"
#import "DGInstructionsListTableViewCell.h"
#import "DGConstants.h"
#import "Flurry.h"

static const NSString * DGAVPlayerKVOContext = @"DGAVPlayerContext";

@interface DBInstructionsViewController ()

@end

@implementation DBInstructionsViewController {
    NSArray *_videoDictsArray;
    NSArray *_adDictsArray;
    NSInteger _currentVideoIndex;
    AVPlayerViewController *_playerViewController;
    BOOL _isPlaying;
}

static NSString *cellIdentifier = @"DGInstructionsListTableViewCell";
static NSString *linkCellIdentifier = @"DGLinkTableViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Instructions page loaded"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    _currentVideoIndex = -1;
    
    // Open file containing list of videos
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success;
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDGVideoListFileName];
    success = [fileManager fileExistsAtPath:defaultPath];
    if (success){
        // Get the data and parse it
        NSData *videoData = [NSData dataWithContentsOfFile:defaultPath];
        NSDictionary *videosDict = [NSJSONSerialization JSONObjectWithData:videoData options:0 error:&error];
        
        // If we successfully parsed it
        if (videosDict && videosDict.count > 0) {
            // Get the array of object dicts
            NSArray *objectArray = [videosDict objectForKey:kDGVideoListKey];
            if (objectArray && [objectArray count] > 0) {
                // Set as array for display
                _videoDictsArray = [NSArray arrayWithArray:objectArray];
            }
        } else {
            NSLog(@"Unable to parse videos file.");
        }
    } else {
        NSLog(@"Unable to find videos file.");
    }
    
    defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDGVAdListFileName];
    success = [fileManager fileExistsAtPath:defaultPath];
    if (success){
        // Get the data and parse it
        NSData *adData = [NSData dataWithContentsOfFile:defaultPath];
        NSDictionary *adDict = [NSJSONSerialization JSONObjectWithData:adData options:0 error:&error];
        
        // If we successfully parsed it
        if (adDict && adDict.count > 0) {
            // Get the array of object dicts
            NSArray *objectArray = [adDict objectForKey:kDGAdArrayKey];
            if (objectArray && [objectArray count] > 0) {
                // Set as array for display
                _adDictsArray = [NSArray arrayWithArray:objectArray];
            }
        } else {
            NSLog(@"Unable to parse ads file.");
        }
    } else {
        NSLog(@"Unable to find ads file.");
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Tear down the old player if one exists
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_playerViewController) {
            [self tearDownPlayer];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
//    // Return a bitmask of supported orientations. If you need more,
//    // use bitwise or (see the commented return).
//    return UIInterfaceOrientationMaskPortrait;
//    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // If the player was paused because the app went into the background
    if (_isPlaying && _playerViewController.player.rate == 0) {
        [_playerViewController.player play];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    // If the player was paused because the app went into the background
    if (_isPlaying && _playerViewController.player.rate == 0) {
        [_playerViewController.player play];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    // Toggle the player state
    if (_isPlaying) {
        [_playerViewController.player pause];
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // Toggle the player state
    if (_isPlaying) {
        [_playerViewController.player pause];
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

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
        // Show/hide fullscreen player
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortrait) {
            // Set the frame
            _playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, kVideoPlayerHeight);
            _tableView.hidden = NO;
            _closeButton.hidden = NO;
        } else {
            _playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            _tableView.hidden = YES;
            _closeButton.hidden = YES;
        }
    }];
}

#pragma mark - Video Player

- (void)tearDownPlayer {
        [_playerViewController.player removeObserver:self forKeyPath:kDGAVPlayerRateKey context:&DGAVPlayerKVOContext];
        _playerViewController.player = nil;
        [_playerViewController.view removeFromSuperview];
        [_playerViewController removeFromParentViewController];
        _playerViewController = nil;
}

- (void)playCurrentVideo {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update the cells
        [self.tableView reloadData];
        
        // Tear down the old player if one exists
        if (_playerViewController) {
            [self tearDownPlayer];
        }
        
        // Grab a local URL to the video
        if (_currentVideoIndex > -1 && _currentVideoIndex < [_videoDictsArray count]) {
            NSDictionary *videoDict = [_videoDictsArray objectAtIndex:_currentVideoIndex];
            NSString *videoFilename = [videoDict objectForKey:kDGVideoFileKey];
            NSURL *videoURL = [[NSBundle mainBundle]URLForResource:videoFilename withExtension:@"MOV"];
            
            // Create an AVPlayer
            AVPlayer *player = [AVPlayer playerWithURL:videoURL];
            NSKeyValueObservingOptions options = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial);
            [player addObserver:self forKeyPath:kDGAVPlayerRateKey options:options context:&DGAVPlayerKVOContext];
            
            // Create a player view controller
            _playerViewController = [[AVPlayerViewController alloc]init];
            _playerViewController.player = player;
            [player play];
            _isPlaying = YES;
            
            // Show the view controller
            [self addChildViewController:_playerViewController];
            [self.view insertSubview:_playerViewController.view atIndex:1]; // Place behind the close button
            
            // Set the frame
            _playerViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, kVideoPlayerHeight);
        }
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // If we receive a notification that the playback rate has changed
    if(object == _playerViewController.player && [keyPath isEqualToString:kDGAVPlayerRateKey]) {
        if (_playerViewController.player.rate == 0) {
            _isPlaying = NO;
        } else {
            _isPlaying = YES;
        }
        // Update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the cells
            [self.tableView reloadData];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_videoDictsArray count];
    } else {
        return [_adDictsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger objectIndex = indexPath.row;
    
    if (indexPath.section == 0) {
        // Setup the custom cell
        DGInstructionsListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        NSDictionary *videoDict = [_videoDictsArray objectAtIndex:objectIndex];
        
        // Set the values
        cell.titleLabel.text = [videoDict objectForKey:kDGVideoNameKey];
        
        // Set the image as the pause icon if this is the cell of the currently playing video
        if (_currentVideoIndex == objectIndex && _isPlaying == YES) {
            cell.playPauseImageView.image = [UIImage imageNamed:@"pause_btn.png"];
        } else {
            cell.playPauseImageView.image = [UIImage imageNamed:@"play_btn.png"];
        }
        
        if (_currentVideoIndex == objectIndex) {
            [cell setSelected:YES];
        }
        
        return cell;
    } else {
        // Just show the add name on the cell
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:linkCellIdentifier];
        NSDictionary *adsDict = [_adDictsArray objectAtIndex:objectIndex];
        cell.textLabel.text = [adsDict objectForKey:kDGAdProductNameKey];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellSingleRowHeight;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return kDGVideoInstructionsLabel;
    } else {
        return kDGHeadsetsLabel;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the selected object
    NSInteger objectIndex = indexPath.row;
    
    // If the videos section was selected
    if (indexPath.section == 0) {
        // If the current video is being played
        if (_currentVideoIndex == objectIndex) {
            // Toggle the player state
            if (_isPlaying) {
                [_playerViewController.player pause];
                _isPlaying = NO;
            } else {
                [_playerViewController.player play];
                _isPlaying = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the cells
                [self.tableView reloadData];
            });
            
        } else {
            NSDictionary *videoDict = [_videoDictsArray objectAtIndex:objectIndex];
            [Flurry logEvent:@"Video Clicked" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[videoDict objectForKey:kDGVideoNameKey], kDGVideoNameKey, nil]];
            // Play the newly selected video
            _currentVideoIndex = objectIndex;
            [self playCurrentVideo];
        }
    } else { // If an ad was selected
        // Open the ad link
        NSDictionary *adsDict = [_adDictsArray objectAtIndex:objectIndex];
        NSString *selectedUrl = [adsDict objectForKey:kDGAdProductURLKey];
        NSURL *requestURL = [[NSURL alloc] initWithString:selectedUrl];
        
        [Flurry logEvent:@"Ad Clicked" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[adsDict objectForKey:kDGAdProductNameKey], kDGAdProductNameKey, nil]];
        
        if ([[UIApplication sharedApplication] canOpenURL:requestURL]) {
            [[UIApplication sharedApplication] openURL:requestURL];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
