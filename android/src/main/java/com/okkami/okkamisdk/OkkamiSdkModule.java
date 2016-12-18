package com.okkami.okkamisdk;

import android.content.Context;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

class OkkamiSdkModule extends ReactContextBaseJavaModule {
    private Context context;
    private static final String TAG = "OKKAMISDK";

    public OkkamiSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }

    /**
     * Connect to room.
     * on success: connectToRoomPromise.resolve(String coreResponseJSONString )
     * on failure:  connectToRoomPromise.resolve(Throwable e)
     *
     * @param username
     * @param password
     * @param connectToRoomPromise
     */
    @ReactMethod
    public void connectToRoom(String username, String password, Promise connectToRoomPromise) {

        Log.d(TAG, "[connectToRoom] username:" + username + " / password:" + password);

        connectToRoomPromise.resolve("{}");
    }


}
