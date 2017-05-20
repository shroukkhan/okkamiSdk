package com.okkami.okkamisdk;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.View;
import android.widget.ProgressBar;

import com.linecorp.linesdk.auth.LineAuthenticationConfig;
import com.linecorp.linesdk.auth.internal.LineAuthenticationActivity;

import java.util.List;

/**
 * Created by game on 5/9/2017 AD.
 */

public class LineAuthActivity extends LineAuthenticationActivity {
    public LineAuthActivity() {
        super();
    }

    @NonNull
    public static Intent a(@NonNull Context var0, @NonNull LineAuthenticationConfig var1, @NonNull List<String> var2) {
        Intent var3;
        (var3 = new Intent(var0, LineAuthActivity.class)).putExtra("authentication_config", var1);
        var3.putExtra("permissions", (String[])var2.toArray(new String[var2.size()]));
        return var3;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.setContentView(R.layout.linesdk_activity_lineauth);
        ProgressBar pb = (ProgressBar) findViewById(R.id.progress_bar_line_login_auth);
        pb.setVisibility(View.INVISIBLE);
//        Log.d("LineAuthActivity", "onCreate: "+pb.toString());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
    }
}
