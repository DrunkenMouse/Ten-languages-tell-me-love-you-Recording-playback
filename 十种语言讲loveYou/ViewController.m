//
//  ViewController.m
//  十种语言讲loveYou
//
//  Created by 王奥东 on 16/12/9.
//  Copyright © 2016年 王奥东. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgVIew;

@end

@implementation ViewController {
    
    IBOutlet UIButton *_playButton;
    NSURL *_recordedFile;
    AVAudioPlayer *_player;
    AVAudioRecorder *_recorder;
    BOOL _isRecording;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //录音与播放的
    _isRecording = NO;
    [_playButton setEnabled:NO];
    _playButton.titleLabel.alpha = 0.5;
    
    _recordedFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        NSLog(@"Error creating session:%@",[sessionError description]);
    }else {
        [session setActive:YES error:nil];
    }
    _imgVIew.hidden = YES;
    
}

//Speak
- (IBAction)clickSpeak:(id)sender {
    
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Language" ofType:@"plist"];
    NSDictionary *diction = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       
        for (int i = 0; i < [diction count]; i++) {
            
            NSDictionary *dict = [diction objectForKey:[NSString stringWithFormat:@"%d",i]];
            AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[dict objectForKey:@"local"]];
            AVSpeechSynthesizer *av = [[AVSpeechSynthesizer alloc] init];
            AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:[dict objectForKey:@"content"]];
            utterance.voice = voice;
            utterance.rate *= 0.7;
            [av speakUtterance:utterance];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.titleLabel.text = [dict objectForKey:@"name"];
            });
            [NSThread sleepForTimeInterval:3];
        }
    });
    
}

//播放
- (IBAction)action:(UIButton *)sender {

    if ([_player isPlaying]) {
        [_player pause];
        [sender setTitle:@"播放" forState:UIControlStateNormal];
    }else {
        [_player play];
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
    }
    
}


//录音
- (IBAction)record:(UIButton *)sender {
    
    _imgVIew.hidden = NO;
    if (!_isRecording) {
        _isRecording = YES;
        [sender setTitle:@"STOP" forState:UIControlStateNormal];
        [_playButton setEnabled:NO];
        [_playButton.titleLabel setAlpha:0.5];
        _recorder  = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:nil error:nil];
        [_recorder prepareToRecord];
        
        [_recorder record];
        _player = nil;
        _imgVIew.hidden = NO;
    } else  {
        _isRecording = NO;
        [sender setTitle:@"录音" forState:UIControlStateNormal];
        [_playButton setEnabled:YES];
        [_playButton.titleLabel setAlpha:1];
        [_recorder stop];
        _recorder = nil;
        
        NSError *playerError;
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
        
        if (_player == nil) {
            NSLog(@"Error creating player:%@",[playerError description]);
            _player.delegate = self;
            _imgVIew.hidden = YES;
        }
    }
    
    
}

    

@end
