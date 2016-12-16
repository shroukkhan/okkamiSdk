import React from 'react-native';

const OkkamiSdk = React.NativeModules.OkkamiSdk;

export default {
  okkamiSdk: (onSuccess, onFailure) => {
    return OkkamiSdk.okkamiSdk(onSuccess, onFailure);
  },
};
