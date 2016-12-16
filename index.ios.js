import React from 'react-native';

const OkkamiSdk = React.NativeModules.OkkamiSdk;

export default {
  okkamiSdk: () => {
    return OkkamiSdk.okkamiSdk();
  },
};
