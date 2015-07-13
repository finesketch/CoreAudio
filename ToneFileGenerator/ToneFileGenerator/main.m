//
//  main.m
//  ToneFileGenerator
//
//  Created by Kyle Chew on 7/12/15.
//  Copyright (c) 2015 FineSketch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100
#define DURATION 5.0
#define FILENAME_FORMAT @"%0.3f-sine.aif"

int main(int argc, const char * argv[]) {
    if (argc < 2) {
        printf("Command Line: ToneFileGenerator < Tone in Hz >");
        return -1;
    }
    
    double hz = atof(argv[1]);
    
    assert(hz > 0);
    
    NSLog(@"Generating %f Hz tone", hz);
    
    NSString *fileName = [NSString stringWithFormat:FILENAME_FORMAT, hz];
    NSString *filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    NSLog(@"Path: %@", fileURL);
    
    // Setup the ASBD format
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = SAMPLE_RATE;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mChannelsPerFrame = 1;
    asbd.mFramesPerPacket = 1;
    asbd.mBitsPerChannel = 16;
    asbd.mBytesPerFrame = 2;
    asbd.mBytesPerPacket = 2;
    
    // Set up the file
    AudioFileID audioFile;
    OSStatus audioErr = noErr;
    audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileURL, kAudioFileAIFFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
                          
    assert(audioErr == noErr);
    
    // Writing samples to the file
    long maxSampleCount = SAMPLE_RATE * DURATION;
    long sampleCount = 0;
    UInt32 bytesToWrite = 2;
    double waveLengthInSamples = SAMPLE_RATE / hz;
    
    NSLog(@"waveLengthInSamples = %f", waveLengthInSamples);
    
    while (sampleCount < maxSampleCount) {
        for (int i = 0; i < waveLengthInSamples; i++) {
            SInt16 sample = CFSwapInt16HostToBig ((SInt16) SHRT_MAX *
                                                  sin (2 * M_PI *
                                                       (i / waveLengthInSamples)));
            audioErr = AudioFileWriteBytes(audioFile,
                                           false,
                                           sampleCount*2,
                                           &bytesToWrite,
                                           &sample);
            assert (audioErr == noErr);
            
            
            sampleCount++;
            
            
        }
    }
    audioErr = AudioFileClose(audioFile);
    assert (audioErr == noErr);
    NSLog (@"wrote %ld samples", sampleCount);
    
    return 0;
}
