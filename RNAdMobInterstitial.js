'use strict';

import {
  NativeModules,
  DeviceEventEmitter,
} from 'react-native';

const RNAdMobInterstitial = NativeModules.RNAdMobInterstitial;

const eventHandlers = {
  interstitialDidLoad: new Map(),
  interstitialDidFailToLoad: new Map(),
  interstitialDidOpen: new Map(),
  interstitialDidClose: new Map(),
  interstitialWillLeaveApplication: new Map(),
};

const addEventListener = (type, handler) => {
  switch (type) {
    case 'interstitialDidLoad':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
      break;
    case 'interstitialDidFailToLoad':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, (error) => { handler(error); }));
      break;
    case 'interstitialDidOpen':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
      break;
    case 'interstitialDidClose':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
      break;
    case 'interstitialWillLeaveApplication':
      eventHandlers[type].set(handler, DeviceEventEmitter.addListener(type, handler));
      break;
    default:
      console.log(`Event with type ${type} does not exist.`);
  }
}

const removeEventListener = (type, handler) => {
  if (!eventHandlers[type].has(handler)) {
    return;
  }
  eventHandlers[type].get(handler).remove();
  eventHandlers[type].delete(handler);
}

const removeAllListeners = () => {
  DeviceEventEmitter.removeAllListeners('interstitialDidLoad');
  DeviceEventEmitter.removeAllListeners('interstitialDidFailToLoad');
  DeviceEventEmitter.removeAllListeners('interstitialDidOpen');
  DeviceEventEmitter.removeAllListeners('interstitialDidClose');
  DeviceEventEmitter.removeAllListeners('interstitialWIllLeaveApplication');
};

// replaces deprecated API
const tryShowNewInterstitial = (testID) => {
  console.warn(`tryShowNewInterstitial method is deprecated and will be removed in the next major release, please use requestAd() and showAd() directly.\n\nExample: AdMobInterstitial.requestAd(AdMobInterstitial.showAd)`);
  if (testID) {
    RNAdMobInterstitial.setTestDeviceID(testID);
  }

  RNAdMobInterstitial.isReady((isReady) => {
    if (isReady) {
      RNAdMobInterstitial.showAd(() => {});
    } else {
      RNAdMobInterstitial.requestAd(() => RNAdMobInterstitial.showAd(() => {}));
    }
  });
};

const setBirthday = (birthday) => {
  if (birthday && birthday instanceof Date) {
    const month = birthday.getMonth() + 1;
    const day = birthday.getDate();
    const year = birthday.getFullYear();
    RNAdMobInterstitial.setBirthday({ day, month, year });
  }
};

const setChildDirected = (childDirected) => {
  RNAdMobInterstitial.setChildDirected(childDirected);
}

const setContentUrl = (contentUrl) => {
  RNAdMobInterstitial.setContentUrl(contentUrl);
}

const setGender = (gender) => {
  RNAdMobInterstitial.setGender(gender);
}

const setLocation = (location) => {
  RNAdMobInterstitial.setLocation(location);
};

const setTargetingData = (targetingData) => {
  const { birthday, childDirected, contentUrl, gender, location } = targetingData;
  birthday && setBirthday(birthday);
  childDirected && setChildDirected(childDirected);
  contentUrl && setContentUrl(contentUrl);
  gender && setGender(gender);
  location && setLocation(location);
};

module.exports = {
  ...RNAdMobInterstitial,
  requestAd: (cb = () => {}) => RNAdMobInterstitial.requestAd(cb), // requestAd callback is optional
  showAd: (cb = () => {}) => RNAdMobInterstitial.showAd(cb),       // showAd callback is optional
  setTargetingData,
  setGender,
  setBirthday,
  setLocation,
  setChildDirected,
  setContentUrl,
  tryShowNewInterstitial,
  addEventListener,
  removeEventListener,
  removeAllListeners,
  setAdUnitId: (id) => {
    RNAdMobInterstitial.setAdUnitID(id);
    console.warn(`setAdUnitId will be deprecated soon. Please use setAdUnitID instead.`);
  },
};
