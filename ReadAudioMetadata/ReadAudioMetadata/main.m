//
//  main.m
//  CoreAudioMetadata
//
//  Created by Kyle Chew on 7/11/15.
//  Copyright (c) 2015 FineSketch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// the main() accepts a count of arguments (argc) and an array of plain C-string arguments.
// The first string is this program name, in this case, it should be CoreAudioMetadata
// Then second argument is path to the audio file
// To pass the parameter during the debug, you can do it in "Edit Scheme > Arguments" section
int main (int argc, const char * argv[]) {
    if (argc < 2) {
        printf("Command Line: CoreAudioMetadata /full/path/to/your/audio/file\n");
        return -1;
    }
    
    // Convert the argument to plain-C string using [NSString stringWithUTF8String:argv[1]]
    // So the path can be in non-Western characters
    // If "~" is used, you need to specify it using stringByExpandingTildeInPath
    NSString *audioFilePath = [[NSString stringWithUTF8String:argv[1]] stringByExpandingTildeInPath];
    
    // NSURL is representation of file paths
    NSURL *audioURL = [NSURL fileURLWithPath:audioFilePath];
    
    NSLog(@"Your Audio Source Path: %@", audioURL);
    
    // Core Audio uses the AudioFileID type to refer to audio file objects
    AudioFileID audioFile;
    
    // Most Core Audio functions signal success or failure through their return value, which is of type OSStatus
    // Any status other than noErr ("0") signals an error.
    // It is important to check for OSStatus for every CoreAudio API call
    OSStatus err = noErr;
    
    // The first Core Audio call is AudioFileOpenURL - open the audio file
    // This API requires 4 parameters:
    // - CFURLRef: NSURL will be auto-map/__bridge to CFURLRef (Core Foundation)
    // - Permission flag: Read flag
    // - File Type hint: No hint - "0"
    // - Pointer to audio file: File path, "&" is used for "Address of"
    err = AudioFileOpenURL((__bridge CFURLRef)audioURL, kAudioFileReadPermission, 0, &audioFile);
    
    // Stop if error returned
    assert(err == noErr);
    
    // Local variable for memory size
    UInt32 dictionarySize = 0;
    
    // Core Audio call AudioFileGetPropertyInfo
    // Use kAudioFilePropertyInfoDictionary to get the audio property info
    // Data will be returned as dictionary object
    err = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
    
    // Stop if error returned
    assert(err == noErr);
    
    // Some properties are numeric; some are strings. Refer to the documentation and the Core Audio header files describe these values.
    CFDictionaryRef dictionary;
    
    // Reading the dictionary object
    err = AudioFileGetProperty(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, &dictionary);
    
    // Stop if error returned
    assert(err == noErr);
    
    // Print the dictionary
    NSLog(@"dictionary: %@", dictionary);
    
    // Release
    CFRelease(dictionary);
    
    // Core Audio call to release all audio object memory
    err = AudioFileClose(audioFile);
    
    // Stop if error returned
    assert(err == noErr);
    
    return 0;
}
