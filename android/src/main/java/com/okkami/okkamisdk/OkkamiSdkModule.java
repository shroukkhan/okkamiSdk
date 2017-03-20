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
import com.okkami.android.sdk.model.DeviceAuth;

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
    private static final int LINE_LOGIN_REQUEST_CODE = 10;
    private SDK okkamiSdk;
    private Promise lineLoginPromise = null;

    private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

        @Override
        public void onActivityResult(Activity activity, int requestCode, int resultCode,
                Intent data) {
            super.onActivityResult(activity, requestCode, resultCode, data);
            Log.d(TAG, "onActivityResult: "+requestCode);
            if (requestCode != LINE_LOGIN_REQUEST_CODE) return;
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
        getCurrentActivity().startActivityForResult(loginIntent, LINE_LOGIN_REQUEST_CODE);
    }

    /**
     * Set new the Smooch app token to Okkami SDK for switching channel to let user talk to different hotels
     * @param appToken - an app token provided by Smooch
     */
    @ReactMethod
     public void setSmoochAppToken(String appToken){
        okkamiSdk.setSmoochAppToken(appToken);
     }

     @ReactMethod
     public void showSmoochUI(){
         okkamiSdk.showSmoochUI();
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
            } else if (getPost.compareTo("GET") == 0){
                okkamiSdk.getBACKEND_SERVICE_MODULE().doCoreGetCall(path, "GET", payload, b)
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


    /**
     * Returns the list of conversations as shown in : https://projects.invisionapp.com/share/2XAK26Y4G#/screens/223142641
     * returns a Promise which resolves to a json like this:
     * <p>
     * {
     * "OKKAMI_CHAT": [
     * {
     * "unread_messages": "2",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "OKKAMI Concierge",
     * "last_message": "We'll be happy to help your find good activities to do tonight",
     * "time_since_last_message": "5 min"
     * }
     * ],
     * "ACTIVE_CHATS": [
     * {
     * "unread_messages": "1",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Intercontinental Montreal",
     * "last_message": "Your room upgrade can be purchased using the link below",
     * "time_since_last_message": "1 hr 10 min"
     * },
     * {
     * "unread_messages": "3",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Aloft Bangkok",
     * "last_message": "Food and wine at XYZ Bar",
     * "time_since_last_message": "5 hr"
     * }
     * ],
     * "INACTIVE_CHATS": [
     * {
     * "unread_messages": "0",
     * "icon": "http://www.vieuxmontreal.ca/wp-content/uploads/2015/07/Intercontinental_logo_233X2331.png",
     * "channel_name": "Grand President Hotel",
     * "last_message": "",
     * "time_since_last_message": ""
     * },
     * {
     * "unread_messages": "0",
     * "icon": "http://orig15.deviantart.net/4679/f/2009/042/f/8/test_by_kaitoukat.png",
     * "channel_name": "Ambassador Bangkok",
     * "last_message": "",
     * "time_since_last_message": ""
     * }
     * ]
     * }
     *
     * @param getConversationListPromise
     */
    @ReactMethod
    public void getConversationsList(Promise getConversationListPromise) {

    }

    /**
     * Open the smooch chat window for a particular channel
     * openChatWindowPromise.resolve(true) on success
     * openChatWindowPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param openChatWindowPromise
     */
   @ReactMethod
    public void openChatWindow(String smoochAppToken, Promise openChatWindowPromise) {

    }


    /**
     * returns the number of unread message in a channel
     * getUnreadMessageCountPromise.resolve(Int) on success
     * getUnreadMessageCountPromise.reject(Exception) on failure
     * @param smoochAppToken
     * @param getUnreadMessageCountPromise
     */
    @ReactMethod
    public void getUnreadMessageCount(String smoochAppToken, Promise getUnreadMessageCountPromise){

    }



}
