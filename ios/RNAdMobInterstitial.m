#import "RNAdMobInterstitial.h"
#import "RCTConvert.h"
#import <CoreLocation/CoreLocation.h>

@implementation RNAdMobInterstitial {
  GADInterstitial  *_interstitial;
  NSString *_adUnitID;
  NSString *_testDeviceID;
  RCTResponseSenderBlock _requestAdCallback;
  RCTResponseSenderBlock _showAdCallback;
  NSCalendar *_birthday;
  GADGender *_gender;
  CLLocation *_location;
}

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

#pragma mark exported methods

RCT_EXPORT_METHOD(setAdUnitID:(NSString *)adUnitID)
{
  _adUnitID = adUnitID;
}

RCT_EXPORT_METHOD(setTestDeviceID:(NSString *)testDeviceID)
{
  _testDeviceID = testDeviceID;
}

RCT_EXPORT_METHOD(setGender:(NSString *)gender)
{
  if([gender isEqualToString:@"male"]){
    _gender = kGADGenderMale;
  } else {
    _gender = kGADGenderFemale;
  }
}

RCT_EXPORT_METHOD(setLocation:(NSDictionary *)coordinates)
{
  if(coordinates[@"lat"] != nil && coordinates[@"long"] != nil){
    _location = [[CLLocation alloc]
                  initWithLatitude:[RCTConvert double:coordinates[@"lat"]]
                  longitude:[RCTConvert double:coordinates[@"long"]]];
  }
}

RCT_EXPORT_METHOD(setBirthday:(NSDictionary *)birthday)
{
  if(birthday[@"month"] != nil && birthday[@"day"] != nil && birthday[@"year"] != nil) {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = [RCTConvert NSInteger:birthday[@"month"]];
    components.day = [RCTConvert NSInteger:birthday[@"day"]];
    components.year = [RCTConvert NSInteger:birthday[@"year"]];
    _birthday = [[NSCalendar currentCalendar] dateFromComponents:components];
  }
}

RCT_EXPORT_METHOD(setTargetingData:(NSDictionary *)targetingData)
{
  if(targetingData[@"gender"] != nil) {
    if([targetingData[@"gender"] isEqualToString:@"male"]){
      _gender = kGADGenderMale;
    } else {
      _gender = kGADGenderFemale;
    }
  }

  if(targetingData[@"month"] != nil && targetingData[@"day"] != nil && targetingData[@"year"] != nil) {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = [RCTConvert NSInteger:targetingData[@"month"]];
    components.day = [RCTConvert NSInteger:targetingData[@"day"]];
    components.year = [RCTConvert NSInteger:targetingData[@"year"]];
    _birthday = [[NSCalendar currentCalendar] dateFromComponents:components];
  }

  if(targetingData[@"lat"] != nil && targetingData[@"long"] != nil){
    _location = [[CLLocation alloc]
                  initWithLatitude:[RCTConvert double:targetingData[@"lat"]]
                  longitude:[RCTConvert double:targetingData[@"long"]]];
  }
}

RCT_EXPORT_METHOD(requestAd:(RCTResponseSenderBlock)callback)
{
  if ([_interstitial hasBeenUsed] || _interstitial == nil) {
    _requestAdCallback = callback;

    _interstitial = [[GADInterstitial alloc] initWithAdUnitID:_adUnitID];
    _interstitial.delegate = self;

    GADRequest *request = [GADRequest request];

    if(_gender != nil){
      request.gender = _gender;
    }
    if(_birthday != nil){
      request.birthday;
    }
    if (_location) {
      [request setLocationWithLatitude:_location.coordinate.latitude
                             longitude:_location.coordinate.longitude
                              accuracy:_location.horizontalAccuracy];
    }

    if(_testDeviceID) {
      if([_testDeviceID isEqualToString:@"EMULATOR"]) {
        request.testDevices = @[kGADSimulatorID];
      } else {
        request.testDevices = @[_testDeviceID];
      }
    }
    [_interstitial loadRequest:request];
  } else {
    callback(@[@"Ad is already loaded."]); // TODO: make proper error via RCTUtils.h
  }
}


RCT_EXPORT_METHOD(showAd:(RCTResponseSenderBlock)callback)
{
  if ([_interstitial isReady]) {
    _showAdCallback = callback;
    [_interstitial presentFromRootViewController:[UIApplication sharedApplication].delegate.window.rootViewController];
  }
  else {
    callback(@[@"Ad is not ready."]); // TODO: make proper error via RCTUtils.h
  }
}

RCT_EXPORT_METHOD(isReady:(RCTResponseSenderBlock)callback)
{
  callback(@[[NSNumber numberWithBool:[_interstitial isReady]]]);
}


#pragma mark delegate events

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interstitialDidLoad" body:nil];
  _requestAdCallback(@[[NSNull null]]);
}

- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interstitialDidFailToLoad" body:@{@"name": [error description]}];
  _requestAdCallback(@[[error description]]);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interstitialDidOpen" body:nil];
  _showAdCallback(@[[NSNull null]]);
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interstitialDidClose" body:nil];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  [self.bridge.eventDispatcher sendDeviceEventWithName:@"interstitialWillLeaveApplication" body:nil];
}

@end
