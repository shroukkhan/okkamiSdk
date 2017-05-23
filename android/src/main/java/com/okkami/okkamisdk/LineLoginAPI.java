package com.okkami.okkamisdk;

import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import com.linecorp.linesdk.LineApiError;
import com.linecorp.linesdk.LineApiResponseCode;
import com.linecorp.linesdk.a.c;
import com.linecorp.linesdk.auth.LineAuthenticationConfig;
import com.linecorp.linesdk.auth.LineLoginApi;
import com.linecorp.linesdk.auth.LineLoginResult;
import com.linecorp.linesdk.auth.internal.LineAuthenticationActivity;

import java.util.Collections;
import java.util.List;

/**
 * Created by game on 5/9/2017 AD.
 */

public class LineLoginAPI {
//    private LineLoginAPI() {
//        super();
//    }


    @NonNull
    public static Intent getLoginIntent(@NonNull Context context, @NonNull String channelId) {
        Log.d("LineLoginAPI", "getLoginIntent: 1111");
        return getLoginIntent(context, (new LineAuthenticationConfig.Builder(channelId)).build(),
                Collections.<String>emptyList());
    }
//
//    @NonNull
//    public static Intent getLoginIntentWithoutLineAppAuth(@NonNull Context context, @NonNull String channelId) {
//        return getLoginIntent(context, (new LineAuthenticationConfig.Builder(channelId)).disableLineAppAuthentication().build(), Collections.emptyList());
//    }
//
//    @NonNull
//    public static Intent getLoginIntent(@NonNull Context context, @NonNull String channelId, @NonNull List<String> permissions) {
//        return getLoginIntent(context, (new LineAuthenticationConfig.Builder(channelId)).build(), permissions);
//    }
//
//    @NonNull
//    public static Intent getLoginIntentWithoutLineAppAuth(@NonNull Context context, @NonNull String channelId, @NonNull List<String> permissions) {
//        return getLoginIntent(context, (new LineAuthenticationConfig.Builder(channelId)).disableLineAppAuthentication().build(), permissions);
//    }

    @NonNull
    public static Intent getLoginIntent(@NonNull Context context, @NonNull LineAuthenticationConfig config, @NonNull List<String> permissions) {
        if(!config.isEncryptorPreparationDisabled()) {
            c.a(context);
        }

        Log.d("LineLoginAPI", "getLoginIntent: 2222");
        return LineAuthActivity.a(context, config, permissions);
    }

//    @NonNull
//    public static LineLoginResult getLoginResultFromIntent(@Nullable Intent intent) {
//        return intent == null?new LineLoginResult(
//                LineApiResponseCode.INTERNAL_ERROR, new LineApiError("Callback intent is null")):LineAuthenticationActivity.a(intent);
//    }
}
