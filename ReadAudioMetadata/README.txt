This example illustrates getting metadata from an audio file like a song downloaded from iTunes or Amazon MP3. The available metadata may depend on file format, version of OS X, and what metadata the vendor has included in the file.

The program runs as a command-line executable and takes as its argument the path to an audio file, meaning you need to either run it from the command line in the Derived Data build directory, or supply arguments as part of the Xcode scheme.

————————————————————————————————

Core Audio Properties

The Core Audio calls in this example were all about getting properties from the audio file object. The routine of preparing for and executing property-setter and property-getter calls is essential in Core Audio.

That’s because Core Audio is a property-driven API. Properties are key-value pairs, with the keys being enumerated integers. The values can be of whatever type the API defines. Each API in Core Audio communicates its capabilities and state via its list of properties. For example, if you look up the AudioFileGetProperty() function in this example, you’ll find a link to a list of Audio File Properties in the documentation. The list, which you can also find by looking in Core Audio’s AudioFile.h header, looks like this: 

kAudioFilePropertyFileFormat = 'ffmt', 
kAudioFilePropertyDataFormat = 'dfmt', 
kAudioFilePropertyIsOptimized = 'optm', 
kAudioFilePropertyMagicCookieData = 'mgic', 
kAudioFilePropertyAudioDataByteCount = 'bcnt', 
... 

These keys are 32-bit integer values that you can read in the documentation and header file as four character codes. As you can see from this list, the four-character codes take advantage of the fact that you can use single quotes to represent char literals in C and spell out clever mnemonics. Assume that fmt is short for “format,” and you can figure out that ffmt is the code for “file format” and dfmt means “data format.” Codes like these are used throughout Core Audio, as property keys and sometimes as error statuses.

Because Core Audio makes so much use of properties, you’ll see common patterns throughout its API for setting and getting properties. You’ve already seen AudioFileGetPropertyInfo() and AudioFileGetProperty(), so it probably won’t surprise you later to encounter AudioQueueGetProperty(), AudioUnitGetProperty(), AudioConverterGetProperty(), and so on. Some APIs provide property listeners that you can register to receive a callback when a property changes. Using callback functions to respond to asynchronous events is a common pattern in Core Audio.

The values that you get or set with these APIs depend on the property being set. You retrieved the kAudioFilePropertyInfoDictionary property, which returned a pointer to a CFDictionaryRef, but if you had asked for a kAudioFilePropertyEstimatedDuration, you’d need to be prepared to accept a pointer to an NSTimeInterval (which is really just a double). This is tremendously powerful because a small number of functions can support a potentially infinite set of properties. However, setting up such calls does involve extra work because you typically have to use the “get property info” call to allocate some memory to receive the property value or to inspect whether the property is writable.

Another point to notice with the property functions is the Core Audio naming conventions for function parameters. Let’s look at the definition of AudioFileGetProperty() from the docs (or the AudioFile.h header): 

OSStatus AudioFileGetProperty ( 
    AudioFileID inAudioFile, 
    AudioFilePropertyID inPropertyID, 
    UInt32 *ioDataSize, 
    void *outPropertyData 
;

Notice the names of the parameters: The use of in, out, or io indicates whether a parameter is used only for input to the function (as with the first two, which indicate the file to use and the property you want), only for output from the function (as with the fourth, outPropertyData, which fills a pointer with the property value), or for input and output (as with the third, ioDataSize, which accepts the size of buffer you allocated for outPropertyData and then writes back the number of bytes actually written into that buffer). You’ll see this naming pattern throughout Core Audio, particularly any time a parameter works with a pointer to populate a value.

————————————————————————————————

Reference:

Adamson, Chris; Avila, Kevin (2012-04-03). Learning Core Audio: A Hands-On Guide to Audio Programming for Mac and iOS (Kindle Locations 804-810). Pearson Education.
