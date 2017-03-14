package com.okkami.okkamisdk;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.facebook.react.ReactInstanceManager;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

import com.fasterxml.jackson.databind.JsonNode;
import com.google.gson.JsonObject;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;
import com.okkami.android.sdk.SDK;
import com.okkami.android.sdk.enums.AUTH_TYPE;
import com.okkami.android.sdk.model.BaseAuthentication;
import com.okkami.android.sdk.model.CompanyAuth;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import okhttp3.ResponseBody;
import retrofit2.Response;

class OkkamiSdkModule extends ReactContextBaseJavaModule {
    private Context context;
    private static final String TAG = "OKKAMISDK";
    private SDK okkamiSdk;
    private Promise lineLoginPromise = null;

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode,
                Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            //            super.onActivityResult(requestCode, resultCode, data);
//            if (requestCode != REQUEST_CODE) {
//                return;
//            }
            Log.d(TAG, "onActivityResult: "+requestCode);
            LineLoginResult result = LineLoginApi.getLoginResultFromIntent(data);
            String accessToken = result.getLineCredential().getAccessToken().getAccessToken();

            switch (result.getResponseCode()) {

                case SUCCESS:
                    // Login is successful
                    // Do something...
                    JSONObject jObj = new JSONObject();
                    try {
                        jObj.put("accessToken", accessToken);
                        jObj.put("user_id", result.getLineProfile().getUserId());
                        jObj.put("display_name", result.getLineProfile().getDisplayName());
                        jObj.put("picture", result.getLineProfile().getPictureUrl().toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                        lineLoginPromise.reject("error", e.getMessage());
                    }

                    lineLoginPromise.resolve(jObj.toString());
//                    Intent transitionIntent = new Intent(this, PostLoginActivity.class);
//
//                    transitionIntent.putExtra("display_name", result.getLineProfile().getDisplayName());
//                    transitionIntent.putExtra("status_message", result.getLineProfile().getStatusMessage());
//                    transitionIntent.putExtra("user_id", result.getLineProfile().getUserId());
//                    transitionIntent.putExtra("picture_url", result.getLineProfile().getPictureUrl().toString());
                    break;
                case CANCEL:
                    // Login was cancelled by the user
                    // Do something...
                    lineLoginPromise.reject("error", "error");
                    break;
                default:
                    // Login was cancelled by the user
                    // Do something...
            }
        }

//        @Override
//        public void onActivityResult(int requestCode, int resultCode, Intent data) {
////            super.onActivityResult(requestCode, resultCode, data);
////            if (requestCode != REQUEST_CODE) {
////                return;
////            }
//            Log.d(TAG, "onActivityResult: "+requestCode);
//            LineLoginResult result = LineLoginApi.getLoginResultFromIntent(data);
//            String accessToken = result.getLineCredential().getAccessToken().getAccessToken();
//
//            switch (result.getResponseCode()) {
//
//                case SUCCESS:
//                    // Login is successful
//                    // Do something...
//                    lineLoginPromise.resolve(accessToken);
////                    Intent transitionIntent = new Intent(this, PostLoginActivity.class);
////
////                    transitionIntent.putExtra("display_name", result.getLineProfile().getDisplayName());
////                    transitionIntent.putExtra("status_message", result.getLineProfile().getStatusMessage());
////                    transitionIntent.putExtra("user_id", result.getLineProfile().getUserId());
////                    transitionIntent.putExtra("picture_url", result.getLineProfile().getPictureUrl().toString());
//                    break;
//                case CANCEL:
//                    // Login was cancelled by the user
//                    // Do something...
//                    lineLoginPromise.reject("error", "error");
//                    break;
//                default:
//                    // Login was cancelled by the user
//                    // Do something...
//            }
//        }
    };

    public OkkamiSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.context = reactContext;

        reactContext.addActivityEventListener(mActivityEventListener);
        okkamiSdk = new SDK().init(context, "https://api.fingi.com"); // TODO : how do we pass the URL dynamically from react??
    }

    /**
     * @return the name of this module. This will be the name used to {@code require()} this module
     * from javascript.
     */
    @Override
    public String getName() {
        return "OkkamiSdk";
    }


     /*-------------------------------------- Utility   --------------------------------------------------*/

    @ReactMethod
    public void lineLogin(Promise lineLoginPromise) {
        this.lineLoginPromise = lineLoginPromise;
        Intent loginIntent = LineLoginApi.getLoginIntent(this.context, "1499319131");
        getCurrentActivity().startActivityForResult(loginIntent, 1);
    }



     /*---------------------------Core------------------------------------------------------------------------*/

    /**
     * The purpose of this method is to provide general purpose way to call any core endpoint.
     * Internally, the downloadPresets,downloadRoomInfo,connectToRoom all of them should use this method.
     * <p>
     * on success : downloadFromCorePromise.resolve(coreResponseJSONString)
     * on failure:  downloadFromCorePromise.reject(Throwable e)
     *
     * @param endPoint full core url . https://api.fingi.com/devices/v1/register
     * @param getPost  "GET" or "POST"
     * @param payload  JSON encoded payload if it is POST
     */
    @ReactMethod
    public void executeCoreRESTCall(String endPoint, String getPost, String payload, String secret, String token, Boolean force, final Promise downloadFromCorePromise) {
        try {
            URL u = new URL(endPoint);
            String path = u.getPath();
            BaseAuthentication b = new CompanyAuth(token, secret);
            if (getPost.compareTo("POST") == 0) {

                okkamiSdk.getBACKEND_SERVICE_MODULE().doCorePostCall(path, "POST", payload, b)
                        .subscribeOn(io.reactivex.schedulers.Schedulers.io())
                        .observeOn(AndroidSchedulers.mainThread())
                        .subscribe(new Observer<Response<ResponseBody>>() {
                            @Override
                            public void onSubscribe(Disposable d) {
                                System.out.println("Disposable method.");
                            }

                            @Override
                            public void onNext(Response<ResponseBody> value) {
                                try {
                                    String x = value.body().string();
                                    downloadFromCorePromise.resolve(x);
                                } catch (Exception e) {
                                    downloadFromCorePromise.reject(e);
                                    // e.printStackTrace();
                                }
                            }

                            @Override
                            public void onError(Throwable e) {
                                downloadFromCorePromise.reject(e);
                            }

                            @Override
                            public void onComplete() {



                                // Nothing for now.
                            }
                        });
            }
        } catch (Exception e) {
            downloadFromCorePromise.reject(e);


        }

    }

    /*-------------------------------------- Hub -------------------------------------------------*/


    /**
     * Connects to hub using the presets and attempts to login ( send IDENTIFY)
     * If Hub is already connected, reply with  hubConnectionPromise.resolve(true)
     * on success: hubConnectionPromise.resolve(true)
     * on failure:  hubConnectionPromise.reject(Throwable e)
     * Native module should also take care of the PING PONG and reconnect if PING drops
     *
     * @param secrect              secrect obtained from core
     * @param token                token obtained from core
     * @param hubConnectionPromise
     */
    @ReactMethod
    public void connectToHub(String secrect, String token, Promise hubConnectionPromise) {

    }

    /**
     * Disconnects and cleans up the existing connection
     * If Hub is already connected, reply with  hubDisconnectionPromise.resolve(true) immediately
     * on success: hubDisconnectionPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
     * @param hubDisconnectionPromise
     */
    @ReactMethod
    public void disconnectFromHub(Promise hubDisconnectionPromise) {

    }

    /**
     * Disconnects and cleans up the existing connection
     * Then attempt to connect to hub again.
     * on success ( hub has been successfully reconnected and logged in ) : hubReconnectionPromise.resolve(true)
     * on failure:  hubReconnectionPromise.reject(Throwable e)
     *
     * @param hubReconnectionPromise
     */
    @ReactMethod
    public void reconnectToHub(Promise hubReconnectionPromise) {

    }

    /**
     * Send command to hub. a command can look like this:
     * POWER light-1 ON
     * 2311 Default | POWER light-1 ON
     * 1234 2311 Default | POWER light-1 ON
     * <p>
     * The native module should fill in the missing info based on the command received
     * such as filling in room , group , none if not provided and skip those if provied already
     * on success ( successful write ) : sendMessageToHubPromise.resolve(true)
     * on failure:  hubDisconnectionPromise.reject(Throwable e)
     *
     * @param sendMessageToHubPromise
     */
    @ReactMethod
    public void sendCommandToHub(String command, Promise sendMessageToHubPromise) {

    }


    /**
     * if hub is currently connected + logged in :
     * hubLoggedPromise.resolve(true);
     * else
     * hubLoggedPromise.resolve(false);
     *
     * @param hubLoggedPromise
     */
    @ReactMethod
    public void isHubLoggedIn(Promise hubLoggedPromise) {
        /*
            //ok
            hubLoggedPromise.resolve(true);
            //not ok!
            hubLoggedPromise.resolve(false);
        */
    }

    /**
     * if hub is currently connected ( regardless of logged in ) :
     * hubConnectedPromise.resolve(true);
     * else
     * hubConnectedPromise.resolve(false);
     *
     * @param hubConnectedPromise
     */
    @ReactMethod
    public void isHubConnected(Promise hubConnectedPromise) {
        /*
            //connected
            hubConnectedPromise.resolve(true);
            //not connected
            hubConnectedPromise.resolve(false);
        */
    }


    //Events emission
    /*
    *  onHubCommand
    *            WritableMap map = Arguments.createMap();
    *            map.putString("command", "1234 2311 Default | POWER light-1 ON");
    *            this.sendEventToJs("onHubCommand", map);
    *  onHubConnected
    *             this.sendEventToJs("onHubConnected", null);
    *  onHubLoggedIn ( when IDENTIFIED is received )
    *             this.sendEventToJs("onHubLoggedIn", null);
    *  onHubDisconnected
    *            WritableMap map = Arguments.createMap();
    *            map.putString("command", "DISCONNECT_REASON");
    *            this.sendEventToJs("onHubDisconnected", map);
    * */

    /*---------------------------------------------------------------------------------------------------*/


}
